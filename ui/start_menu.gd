extends Control

const GAME_SCENE := "res://scenes/city.tscn"

@onready var start_button: Button = %StartButton
@onready var status_label: Label = get_node_or_null("%StatusLabel") as Label

var _is_transitioning := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if GameManager.is_database_ready:
		_on_database_loaded()
	else:
		start_button.disabled = true
		_set_status("Loading database...")
		GameManager.database_loaded.connect(_on_database_loaded, CONNECT_ONE_SHOT)

func _unhandled_input(event: InputEvent) -> void:
	if _is_transitioning:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_quit_button_pressed()

func _on_database_loaded() -> void:
	_set_status("Database ready")
	start_button.disabled = false
	start_button.grab_focus()


func _set_status(message: String) -> void:
	if status_label:
		status_label.text = message

func _on_start_button_pressed() -> void:
	if _is_transitioning or !GameManager.is_database_ready:
		return

	_is_transitioning = true
	start_button.disabled = true
	_set_status("Starting shift...")
	QuestSystem.reset_run()
	GameManager.request_first_day_notes()
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
