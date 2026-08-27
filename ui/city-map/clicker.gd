extends StaticBody2D

@export var astar_graph_2d: AStarGraph2D
var astar: AStar2D

func _ready() -> void:
	assert(astar_graph_2d)
	astar = astar_graph_2d.build_astar()
	print(astar.get_point_ids())
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("Click ", event)
