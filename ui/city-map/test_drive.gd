extends Node2D

@export var astar_graph_2d: AStarGraph2D
## Plain markers — placed anywhere, not necessarily on the graph itself.
## The nearest PathNode2D to each is used as the actual route endpoint.
@export var start_marker: Node2D
@export var end_marker: Node2D
@export var speed: float = 200.0
@export var arrive_threshold: float = 8.0

var astar: AStar2D
var path: PackedVector2Array
var path_index: int = 0

@onready var car: CharacterBody2D = %Car

func _ready() -> void:
	assert(astar_graph_2d)
	assert(start_marker)
	assert(end_marker)

	astar = astar_graph_2d.build_astar()

	var start_node := astar_graph_2d.find_closest_point(start_marker.global_position)
	var end_node := astar_graph_2d.find_closest_point(end_marker.global_position)
	assert(start_node and end_node, "astar_graph_2d has no PathNode2D children")

	var from_id := astar_graph_2d.get_id_for(start_node)
	var to_id := astar_graph_2d.get_id_for(end_node)
	
	car.global_position = astar.get_point_position(from_id)

	path = astar.get_point_path(from_id, to_id)
	path_index = 0

	if path.is_empty():
		push_warning("No path found between start_marker and end_marker.")

func _physics_process(_delta: float) -> void:
	if path_index >= path.size():
		car.velocity = Vector2.ZERO
		car.move_and_slide()
		return

	var target := path[path_index]
	var to_target := target - car.global_position

	if to_target.length() <= arrive_threshold:
		path_index += 1
		if path_index >= path.size():
			car.velocity = Vector2.ZERO
			car.move_and_slide()
			return
		target = path[path_index]
		to_target = target - car.global_position

	car.velocity = to_target.normalized() * speed
	# Optional: point the sprite the way it's driving.
	# car.rotation = to_target.angle()
	car.move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("Click ", event)
