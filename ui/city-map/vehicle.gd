class_name Vehicle
extends CharacterBody2D
## Moves along whatever path it's given. Knows nothing about AStarGraph2D,
## markers, or how the path was computed — just follows PackedVector2Array
## points in order. Attach directly to the CharacterBody2D node.

@export var home: PathNode2D
@export var work: PathNode2D

enum WorkShift {
	Day,
	Evening,
	Night
}
@export var work_shift: WorkShift

#@export var destinations: Array

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
	var start_node := astar.find_closest_node_of_type(global_position, PathNode2D.NodeType.Residence)
	home = start_node
	global_position = start_node.global_position
	
	#seed(-7718)
	var vehicle = GameManager.database.rms_vehicles.pick_random()
	plate = vehicle.plate
	color = vehicle.color
	type = vehicle.type
	features = vehicle.features

func get_new_path():
	var time := city_map.current_time
	match work_shift:
		WorkShift.Day:
			time += 0
		WorkShift.Evening:
			time += 8 * 60*60
		WorkShift.Night:
			time += 16 * 60*60
	
	var hour = Time.get_datetime_dict_from_unix_time(int(time)).hour
	
	# Find a destination
	var destination: PathNode2D
	
	if hour > 21 or hour < 6:
		if home:
			destination = home
	elif hour >=8 and hour <= 4:
		if work:
			destination = work
	
	if !destination:
		destination = astar._get_path_nodes(PathNode2D.NodeType.POI).pick_random()
	
	var start_node := astar.find_closest_point(global_position)
	var end_node := astar.find_closest_point(destination.global_position)
	
	var from_id := astar.get_id_for(start_node)
	var to_id := astar.get_id_for(end_node)
	
	var new_path := city_map.astar.get_point_path(from_id, to_id)
	if new_path.is_empty():
		push_warning("No path found between start_marker and end_marker.")
	follow_path(new_path)

func _physics_process(_delta: float) -> void:
	if is_done():
		velocity = Vector2.ZERO
		move_and_slide()
		
		var random_wait = randf() * 4
		set_physics_process(false)
		await get_tree().create_timer(random_wait).timeout 
		get_new_path()
		set_physics_process(true)
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
