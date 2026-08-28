class_name CityMap
extends Node2D

@export var astar_graph_2d: AStarGraph2D

@export var time_warp_factor := 60*60 * 0.5
@export var start_time_string: String
@export_storage var start_time: int

var astar: AStar2D
var current_time: float

func _physics_process(delta: float) -> void:
	current_time += delta * time_warp_factor
	$TimeLabel.text = DateHelper.time_12h(int(current_time))

func _ready() -> void:
	assert(astar_graph_2d)
	astar = astar_graph_2d.build_astar()
	
	start_time = Time.get_unix_time_from_datetime_string(start_time_string)
	assert(start_time > 0)
	current_time = start_time

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("Click ", event)
