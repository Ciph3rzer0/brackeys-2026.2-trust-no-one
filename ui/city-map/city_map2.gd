class_name CityMap
extends Node2D
## Resolves start/end markers to graph nodes, computes a route, and hands
## it to the Car to actually drive. All routing/pathfinding setup lives
## here; Car itself stays ignorant of any of it.

@export var astar_graph_2d: AStarGraph2D
## Plain markers — placed anywhere, not necessarily on the graph itself.
## The nearest PathNode2D to each is used as the actual route endpoint.
@export var start_marker: Node2D
@export var end_marker: Node2D
@export var vehicle: Vehicle

@export var time_warp_factor := 60*60 * 0.5
@export var start_time_string: String
@export_storage var start_time: int

var astar: AStar2D
var current_time: float

func _physics_process(delta: float) -> void:
	current_time += delta * time_warp_factor
	$TimeLabel.text = DateHelper.time_12h(current_time)

func _ready() -> void:
	assert(astar_graph_2d)
	assert(vehicle)
	assert(start_marker)
	assert(end_marker)
	
	astar = astar_graph_2d.build_astar()
	
	var start_node := astar_graph_2d.find_closest_point(start_marker.global_position)
	var end_node := astar_graph_2d.find_closest_point(end_marker.global_position)
	assert(start_node and end_node, "astar_graph_2d has no PathNode2D children")
	
	var from_id := astar_graph_2d.get_id_for(start_node)
	var to_id := astar_graph_2d.get_id_for(end_node)
	
	var path := astar.get_point_path(from_id, to_id)
	if path.is_empty():
		push_warning("No path found between start_marker and end_marker.")
	
	vehicle.follow_path(path)
	
	start_time = Time.get_unix_time_from_datetime_string(start_time_string)
	assert(start_time > 0)
	current_time = start_time

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("Click ", event)
