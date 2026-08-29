class_name TownRulesMenu
extends CanvasLayer

@onready var close_button: Button = %CloseButton

var _active_player: Player
var _opened_frame := -1


func _ready() -> void:
	close_button.pressed.connect(close_menu)


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
	if _active_player:
		_active_player.set_mouse_free(true)
	close_button.grab_focus()


func close_menu() -> void:
	if !visible:
		return

	visible = false
	if is_instance_valid(_active_player):
		_active_player.set_mouse_free(false)
	_active_player = null
