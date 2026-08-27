class_name Vehicle
extends CharacterBody2D
## Moves along whatever path it's given. Knows nothing about AStarGraph2D,
## markers, or how the path was computed — just follows PackedVector2Array
## points in order. Attach directly to the CharacterBody2D node.

@export var city_map: CityMap
@export var astar: AStarGraph2D
@export var speed: float = 200.0
@export var arrive_threshold: float = 8.0

var plate: String
var color: String
var type: String
var features: Array[String]

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

func _ready() -> void:
	assert(city_map)
	assert(astar)
	var start_node := astar.find_closest_poi(global_position)
	global_position = start_node.global_position
	
	#seed(-7718)
	var vehicle = GameManager.database.rms_vehicles.pick_random()
	plate = vehicle.plate
	color = vehicle.color
	type = vehicle.type
	features = vehicle.features

func get_new_path():
	var destination = astar._get_path_nodes().pick_random()
	var start_node := astar.find_closest_point(global_position)
	var end_node := astar.find_closest_point(destination.global_position)
	pass
	var from_id := astar.get_id_for(start_node)
	var to_id := astar.get_id_for(end_node)

	var path := city_map.astar.get_point_path(from_id, to_id)
	if path.is_empty():
		push_warning("No path found between start_marker and end_marker.")
	follow_path(path)

func _physics_process(_delta: float) -> void:
	if is_done():
		velocity = Vector2.ZERO
		move_and_slide()
		get_new_path()
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
