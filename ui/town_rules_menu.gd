class_name TownRulesMenu
extends CanvasLayer

@onready var close_button: Button = %CloseButton
@onready var rules_scroll: ScrollContainer = %RulesScroll

var _active_player: Player
var _opened_frame := -1


func _ready() -> void:
	# The scene is visible by default so its layout can be previewed in the
	# 2D editor. Always begin closed when the game actually runs.
	visible = false
	close_button.pressed.connect(close_menu)
	if GameManager.consume_first_day_notes_request():
		_open_requested_notes.call_deferred()


func _open_requested_notes() -> void:
	var player := GameManager.player if is_instance_valid(GameManager.player) else null
	open_menu(player)


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
	rules_scroll.scroll_vertical = 0
	visible = true
	if _active_player:
		_active_player.set_mouse_free(true)
	rules_scroll.grab_focus()


func close_menu() -> void:
	if !visible:
		return

	visible = false
	if is_instance_valid(_active_player):
		_active_player.set_mouse_free(false)
	_active_player = null
