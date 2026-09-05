class_name WaypointMarker
extends Control

@export var target: Node3D          # The 3D object to track
@export var margin: float = 32.0     # Pixels away from the screen edge

@onready var arrow: Control = $Arrow
@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _process(_delta: float) -> void:
	if not is_instance_valid(target) or not camera:
		hide()
		return

	var global_pos: Vector3 = target.global_position
	
	# 1. Project to 2D to see where it would be if it's strictly in front
	var screen_pos: Vector2 = camera.unproject_position(global_pos)
	var viewport_size: Vector2 = get_viewport_rect().size
	var screen_center: Vector2 = viewport_size / 2.0
	
	# Check if the target is physically behind the camera plane
	var is_behind: bool = camera.is_position_behind(global_pos)

	# Check if the projected position is off the visible screen edges
	var is_offscreen: bool = (
		screen_pos.x < margin or 
		screen_pos.x > viewport_size.x - margin or 
		screen_pos.y < margin or 
		screen_pos.y > viewport_size.y - margin
	)

	# If it's fully onscreen and in front, hide the arrow tracker
	if not is_offscreen and not is_behind:
		hide() 
		return
		
	show()

	# 2. FIX FOR THE 90-DEGREE FLIP: Calculate direction using true 3D space
	# Get the camera's local transform matrix
	var cam_transform: Transform3D = camera.global_transform
	
	# Vector pointing from the camera to the target in world space
	var to_target_3d: Vector3 = global_pos - cam_transform.origin
	
	# Extract the Right (X) and Up (Y) depth offsets relative to the camera's face
	# cam_transform.basis.x is the camera's "Right" vector
	# cam_transform.basis.y is the camera's "Up" vector
	var local_x: float = to_target_3d.dot(cam_transform.basis.x)
	var local_y: float = to_target_3d.dot(cam_transform.basis.y)
	
	# Create a true 2D direction pointing from screen center to target
	# 2D Screen Y goes DOWN, but 3D Up goes UP, so invert local_y
	var direction: Vector2 = Vector2(local_x, -local_y).normalized()

	# 3. Use Bounding Box Intersection to stick the arrow perfectly to the rim
	var clamped_x: float = screen_center.x
	var clamped_y: float = screen_center.y
	var max_slope: Vector2 = (viewport_size / 2.0) - Vector2(margin, margin)
	
	if abs(direction.x) * max_slope.y > abs(direction.y) * max_slope.x:
		# Hits left or right boundary
		clamped_x = screen_center.x + sign(direction.x) * max_slope.x
		clamped_y = screen_center.y + direction.y * (max_slope.x / abs(direction.x))
	else:
		# Hits top or bottom boundary
		clamped_x = screen_center.x + direction.x * (max_slope.y / abs(direction.y))
		clamped_y = screen_center.y + sign(direction.y) * max_slope.y

	# 4. Position and rotate the centered vector arrow
	arrow.global_position = Vector2(clamped_x, clamped_y)
	arrow.rotation = direction.angle()
