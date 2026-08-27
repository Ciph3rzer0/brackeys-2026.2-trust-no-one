extends Sprite2D

@export var astar_graph_2d: AStarGraph2D
var astar: AStar2D
@onready var car: CharacterBody2D = %Car

func _ready() -> void:
	assert(astar_graph_2d)
	astar = astar_graph_2d.build_astar()
	print(astar.get_point_ids())
	car.velocity = Vector2.ONE
	pass


func _physics_process(delta: float) -> void:
	car.move_and_slide()
	print(car.position)
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("Click ", event)
