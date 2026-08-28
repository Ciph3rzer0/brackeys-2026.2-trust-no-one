class_name AudioOptionsMenu
extends CanvasLayer

const MASTER_BUS := &"Master"
const MUSIC_BUS := &"Music"
const SFX_BUS := &"SFX"
const OPTIONS_LOWPASS_NAME := "OptionsMenuLowPass"

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var close_button: Button = %CloseButton

var _active_player: Player
var _opened_frame := -1
var _master_bus_index := -1
var _music_bus_index := -1
var _sfx_bus_index := -1


func _ready() -> void:
	_master_bus_index = AudioServer.get_bus_index(MASTER_BUS)
	_music_bus_index = AudioServer.get_bus_index(MUSIC_BUS)
	_sfx_bus_index = AudioServer.get_bus_index(SFX_BUS)

	_sync_slider(master_slider, _master_bus_index)
	_sync_slider(music_slider, _music_bus_index)
	_sync_slider(sfx_slider, _sfx_bus_index)

	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	close_button.pressed.connect(close_menu)
	_set_lowpass_enabled(false)


func _process(_delta: float) -> void:
	if !visible or Engine.get_process_frames() <= _opened_frame:
		return

	if Input.is_action_just_pressed("pc_interact") or Input.is_action_just_pressed("ui_cancel"):
		close_menu()


func toggle_menu(player: Player = null) -> void:
	if visible:
		close_menu()
	else:
		open_menu(player)


func open_menu(player: Player = null) -> void:
	_active_player = player
	_opened_frame = Engine.get_process_frames()
	visible = true
	_set_lowpass_enabled(true)
	if _active_player:
		_active_player.set_mouse_free(true)
	master_slider.grab_focus()


func close_menu() -> void:
	if !visible:
		return

	visible = false
	_set_lowpass_enabled(false)
	if is_instance_valid(_active_player):
		_active_player.set_mouse_free(false)
	_active_player = null


func _exit_tree() -> void:
	_set_lowpass_enabled(false)


func _sync_slider(slider: HSlider, bus_index: int) -> void:
	if bus_index < 0:
		slider.editable = false
		return

	if AudioServer.is_bus_mute(bus_index):
		slider.value = 0.0
	else:
		var linear_volume := db_to_linear(AudioServer.get_bus_volume_db(bus_index))
		slider.value = clampf(linear_volume * 100.0, 0.0, 100.0)


func _set_bus_volume(bus_index: int, slider_value: float) -> void:
	if bus_index < 0:
		return

	var linear_volume := slider_value / 100.0
	var should_mute := is_zero_approx(linear_volume)
	AudioServer.set_bus_mute(bus_index, should_mute)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(linear_volume, 0.0001)))


func _set_lowpass_enabled(enabled: bool) -> void:
	if _master_bus_index < 0:
		_master_bus_index = AudioServer.get_bus_index(MASTER_BUS)
	if _master_bus_index < 0:
		return

	for effect_index in AudioServer.get_bus_effect_count(_master_bus_index):
		var effect := AudioServer.get_bus_effect(_master_bus_index, effect_index)
		if effect is AudioEffectLowPassFilter and effect.resource_name == OPTIONS_LOWPASS_NAME:
			AudioServer.set_bus_effect_enabled(_master_bus_index, effect_index, enabled)
			return


func _on_master_volume_changed(value: float) -> void:
	_set_bus_volume(_master_bus_index, value)


func _on_music_volume_changed(value: float) -> void:
	_set_bus_volume(_music_bus_index, value)


func _on_sfx_volume_changed(value: float) -> void:
	_set_bus_volume(_sfx_bus_index, value)
