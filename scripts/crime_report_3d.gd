class_name CrimeReport3D
extends StaticBody3D

@export var quest: Quest:
	set(value):
		quest = value
		if is_node_ready():
			_apply_quest()

@export var report_number := 0:
	set(value):
		report_number = value
		if is_node_ready():
			_apply_report_number()

var current_holder: ReportHolder3D

@onready var report_sprite: Sprite3D = $Sprite3D
@onready var report_viewport: SubViewport = $SubViewport
@onready var report_ui: Control = $SubViewport/CrimeReport

func _ready() -> void:
	report_sprite.texture = report_viewport.get_texture()
	_apply_quest()
	_apply_report_number()
	if is_instance_valid(GameManager.player):
		GameManager.player.register_input_viewport(report_viewport)


func _exit_tree() -> void:
	if is_instance_valid(GameManager.player):
		GameManager.player.unregister_input_viewport(report_viewport)

func _apply_quest() -> void:
	if quest and report_ui.has_method("set_quest"):
		report_ui.set_quest(quest)


func _apply_report_number() -> void:
	if report_ui.has_method("set_report_number"):
		report_ui.set_report_number(report_number)

func can_interact(player: Player) -> bool:
	return player != null and !player.has_held_report()

func get_interaction_text(_player: Player) -> String:
	return "press e to pick up report"

func interact(player: Player = null) -> void:
	if !player:
		player = GameManager.player
	if player:
		player.pick_up_report(self)

func set_held(is_held: bool) -> void:
	report_sprite.no_depth_test = is_held

func get_report_title() -> String:
	if quest and !quest.incident.is_empty():
		return quest.incident
	return name

func get_plate_entry() -> String:
	return $SubViewport/CrimeReport.get_plate_entry()


@export var crime_report_viewport: SubViewport
@export var quad_mesh: QuadMesh

var screen_size: Vector2
func _input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	# push_input() updates the SubViewport's own GUI hover state, but nothing
	# propagates that to the real OS cursor automatically — only the actual
	# window-owning viewport gets that for free. Drive it manually.
	if event is InputEventMouseMotion:
		var hovered := crime_report_viewport.gui_get_hovered_control()
		if hovered:
			# Control.CursorShape and Input.CursorShape are distinct enum
			# types to GDScript despite matching values — int() bridges them.
			Input.set_default_cursor_shape(int(hovered.get_cursor_shape(hovered.get_local_mouse_position())))
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if (
			event is InputEventMouseButton
			and event.pressed
			and is_instance_valid(GameManager.player)
		):
			GameManager.player.set_active_input_viewport(crime_report_viewport)

		# transform 3D click local to this object.
		var local := to_local(event_position)
		#spawn_sphere_3d(local)
		
		# Convert 3D local click to screen space (0..1)
		var uv := Vector2(
			local.x / screen_size.x + 0.5,
			0.5 - local.y / screen_size.y
		)
		
		# Duplicate Input event
		var translated_input_event = event.duplicate()
		
		# Translate the input into the viewport screen space
		var vp_pos := uv * Vector2(crime_report_viewport.size)
		translated_input_event.position = Vector2(vp_pos)
		
		# Push the translated input event into the computer monitor viewport
		crime_report_viewport.push_input(translated_input_event, true)
		get_viewport().set_input_as_handled()
