extends StaticBody3D

@export var computer_viewport: SubViewport
@export var quad_mesh: QuadMesh

var screen_size: Vector2
func _ready() -> void:
	screen_size = quad_mesh.size

func _input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		# transform 3D click local to this object.
		var local := to_local(event_position)
		#spawn_sphere_3d(local)
		
		# Convert 3D local click to screen space (0..1)
		var uv := Vector2(
			local.x / screen_size.x + 0.5,
			0.5 - local.y / screen_size.y
		)
		
		# Duplicate the current input
		var translated_input_event = event.duplicate()

		# Translate the input to computer screen space
		translated_input_event.position = Vector2(uv.x * 1280, uv.y * 1200)

		# Push the event to the computer monitor viewport
		computer_viewport.push_input(translated_input_event, true)

		# Set World input as handled
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
