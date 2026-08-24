extends Panel

@export_file("*.tscn") var content_scene_path: String
@export var resize_margin: float = 8.0
@export var min_panel_size: Vector2 = Vector2(150, 100)

@onready var content_container: MarginContainer = %Content

enum Mode { NONE, RESIZE_R, RESIZE_B, RESIZE_BR }
var current_mode = Mode.NONE
var drag_offset: Vector2 = Vector2.ZERO
var is_dragging: bool = false

func _ready() -> void:
	%TitleBar.gui_input.connect(_on_title_bar_gui_input)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_load_window_content()

func _load_window_content() -> void:
	if content_scene_path.is_empty():
		return
		
	# Clear any temporary placeholder scenes
	for child in content_container.get_children():
		child.queue_free()
		
	# Load and instance the custom scene
	var loaded_resource = load(content_scene_path)
	if loaded_resource:
		var scene_instance = loaded_resource.instantiate()
		content_container.add_child(scene_instance)

func _process(_delta: float) -> void:
	if current_mode == Mode.NONE and not is_dragging:
		_update_cursor_shape()

func _gui_input(event: InputEvent) -> void:
	if is_dragging:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_determine_resize_mode(event.position)
		else:
			current_mode = Mode.NONE
			accept_event()

	elif event is InputEventMouseMotion:
		_handle_resize_motion(event)

func _on_title_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_offset = get_global_mouse_position() - global_position
			accept_event()
		else:
			is_dragging = false
			accept_event()
			
	elif event is InputEventMouseMotion and is_dragging:
		global_position = get_global_mouse_position() - drag_offset
		accept_event()

func _determine_resize_mode(mouse_pos: Vector2) -> void:
	var on_right = mouse_pos.x >= size.x - resize_margin
	var on_bottom = mouse_pos.y >= size.y - resize_margin
	
	if on_right and on_bottom:
		current_mode = Mode.RESIZE_BR
	elif on_right:
		current_mode = Mode.RESIZE_R
	elif on_bottom:
		current_mode = Mode.RESIZE_B
	else:
		current_mode = Mode.NONE

	if current_mode != Mode.NONE:
		accept_event()

func _handle_resize_motion(_event: InputEventMouseMotion) -> void:
	var global_mouse = get_global_mouse_position()
	
	match current_mode:
		Mode.RESIZE_R:
			size.x = max(min_panel_size.x, global_mouse.x - global_position.x)
			accept_event()
		Mode.RESIZE_B:
			size.y = max(min_panel_size.y, global_mouse.y - global_position.y)
			accept_event()
		Mode.RESIZE_BR:
			size.x = max(min_panel_size.x, global_mouse.x - global_position.x)
			size.y = max(min_panel_size.y, global_mouse.y - global_position.y)
			accept_event()

func _update_cursor_shape() -> void:
	var mouse_pos = get_local_mouse_position()
	var on_right = mouse_pos.x >= size.x - resize_margin and mouse_pos.x <= size.x
	var on_bottom = mouse_pos.y >= size.y - resize_margin and mouse_pos.y <= size.y
	
	if on_right and on_bottom:
		mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	elif on_right:
		mouse_default_cursor_shape = Control.CURSOR_HSIZE
	elif on_bottom:
		mouse_default_cursor_shape = Control.CURSOR_VSIZE
	else:
		mouse_default_cursor_shape = Control.CURSOR_ARROW


func _on_minimize_button_pressed() -> void:
	content_container.visible = !content_container.visible
