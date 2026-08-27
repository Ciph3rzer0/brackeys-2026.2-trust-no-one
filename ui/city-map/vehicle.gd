class_name Vehicle
extends CharacterBody2D
## Moves along whatever path it's given. Knows nothing about AStarGraph2D,
## markers, or how the path was computed — just follows PackedVector2Array
## points in order. Attach directly to the CharacterBody2D node.

@export var speed: float = 200.0
@export var arrive_threshold: float = 8.0

var path: PackedVector2Array
var path_index: int = 0

## Assigns a new path and snaps to its start. Call this whenever a route
## controller (or anything else) computes a path for this vehicle to follow.
func follow_path(new_path: PackedVector2Array) -> void:
	path = new_path
	path_index = 0
	if not path.is_empty():
		global_position = path[0]

func is_done() -> bool:
	return path_index >= path.size()

func _physics_process(_delta: float) -> void:
	if is_done():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var target := path[path_index]
	var to_target := target - global_position

	if to_target.length() <= arrive_threshold:
		path_index += 1
		if is_done():
			velocity = Vector2.ZERO
			move_and_slide()
			return
		target = path[path_index]
		to_target = target - global_position

	velocity = to_target.normalized() * speed
	# Optional: point the sprite the way it's driving.
	# rotation = to_target.angle()
	move_and_slide()
