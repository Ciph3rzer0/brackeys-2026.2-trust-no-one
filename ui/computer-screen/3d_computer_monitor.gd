extends StaticBody3D

const TYPING_SOUNDS: Array[AudioStream] = [
	preload("res://assets/audio/sfx/click-1.wav"),
	preload("res://assets/audio/sfx/click-2.wav"),
	preload("res://assets/audio/sfx/click-3.wav"),
]

@export var computer_viewport: SubViewport
@export var quad_mesh: QuadMesh

var screen_size: Vector2
var _typing_sound_player: AudioStreamPlayer3D


func _ready() -> void:
	screen_size = quad_mesh.size
	_typing_sound_player = AudioStreamPlayer3D.new()
	_typing_sound_player.name = "TypingSoundPlayer"
	_typing_sound_player.bus = &"SFX"
	_typing_sound_player.volume_db = 15.0
	_typing_sound_player.max_polyphony = 4
	add_child(_typing_sound_player)


func push_keypress_to_viewport(event: InputEventKey) -> bool:
	var key_event_copy := event.duplicate()

	# Push the input event into the computer monitor viewport.
	computer_viewport.push_input(key_event_copy, true)
	if event.pressed:
		_play_typing_sound()
	get_viewport().set_input_as_handled()
	return true


func _play_typing_sound() -> void:
	_typing_sound_player.stream = TYPING_SOUNDS.pick_random()
	_typing_sound_player.play()

func _input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	# push_input() updates the SubViewport's own GUI hover state, but nothing
	# propagates that to the real OS cursor automatically — only the actual
	# window-owning viewport gets that for free. Drive it manually.
	print("event ", event)
	if event is InputEventMouseMotion:
		print("hi")
		var hovered := computer_viewport.gui_get_hovered_control()
		if hovered:
			# Control.CursorShape and Input.CursorShape are distinct enum
			# types to GDScript despite matching values — int() bridges them.
			Input.set_default_cursor_shape(int(hovered.get_cursor_shape(hovered.get_local_mouse_position())))
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	if event is InputEventMouseButton or event is InputEventMouseMotion:
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
		var vp_pos := uv * Vector2(computer_viewport.size)
		translated_input_event.position = Vector2(vp_pos)
		
		# Push the translated input event into the computer monitor viewport
		computer_viewport.push_input(translated_input_event, true)
		get_viewport().set_input_as_handled()


func spawn_sphere_3d(spawn_position: Vector3):
	var mesh_instance = MeshInstance3D.new()
	var sphere = SphereMesh.new()

	# Configure dimensions for a sphere
	sphere.radius = 0.05
	sphere.height = 0.1

	mesh_instance.mesh = sphere
	mesh_instance.position = spawn_position

	# Add as a child to the current node
	add_child(mesh_instance)
