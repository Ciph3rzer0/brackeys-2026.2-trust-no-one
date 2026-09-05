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
	
	# 1. Check if the target is in front of or behind the camera
	var is_behind: bool = camera.is_position_behind(global_pos)
	
	# 2. Project 3D position to 2D screen coordinates
	var screen_pos: Vector2 = camera.unproject_position(global_pos)
	var viewport_size: Vector2 = get_viewport_rect().size
	var screen_center: Vector2 = viewport_size / 2.0

	# 3. Determine if it's offscreen
	var is_offscreen: bool = (
		screen_pos.x < margin or 
		screen_pos.x > viewport_size.x - margin or 
		screen_pos.y < margin or 
		screen_pos.y > viewport_size.y - margin
	)

	# If it's onscreen and in front, hide the offscreen arrow (or position it directly over the target)
	if not is_offscreen and not is_behind:
		hide() 
		return
		
	show()

	# 4. Flip the projection vector if the target is behind the camera
	if is_behind:
		screen_pos = screen_center - (screen_pos - screen_center)

	# 5. Calculate direction from screen center to target screen position
	var direction: Vector2 = (screen_pos - screen_center).normalized()

	# 6. Clamp the position to the viewport bounds with margins
	var clamped_x: float = clamp(screen_pos.x, margin, viewport_size.x - margin)
	var clamped_y: float = clamp(screen_pos.y, margin, viewport_size.y - margin)
	
	# Alternatively, for perfect radial clamping along the screen boundary:
	# (This is standard bounding-box ray intersection)
	var max_slope: Vector2 = (viewport_size / 2.0) - Vector2(margin, margin)
	if abs(direction.x) * max_slope.y > abs(direction.y) * max_slope.x:
		# Hits left or right boundary
		clamped_x = screen_center.x + sign(direction.x) * max_slope.x
		clamped_y = screen_center.y + direction.y * (max_slope.x / abs(direction.x))
	else:
		# Hits top or bottom boundary
		clamped_x = screen_center.x + direction.x * (max_slope.y / abs(direction.y))
		clamped_y = screen_center.y + sign(direction.y) * max_slope.y

	# 7. Apply position and rotation to the arrow
	# Since (0,0) is now the center of the arrow, we do not subtract size offsets!
	arrow.global_position = Vector2(clamped_x, clamped_y)
	arrow.rotation = direction.angle()
