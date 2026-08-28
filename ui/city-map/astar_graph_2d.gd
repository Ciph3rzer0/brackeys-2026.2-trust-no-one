@tool
class_name AStarGraph2D
extends Node2D
## Editor-time A* graph authoring tool.
## Add PathNode2D children under this node for vertices; set each one's
## `connections` array (drag other PathNode2D nodes from the tree into it)
## for edges. Nodes/edges draw live in the 2D viewport while editing.
##
## At runtime, call build_astar() once to get a real AStar2D for pathfinding.

@export var node_color: Color = Color.CYAN
@export var edge_color: Color = Color(1.0, 0.9, 0.2, 0.8)
@export var node_radius: float = 6.0
@export var edge_width: float = 4.0

## If false, connections are one-way (A -> B only, unless B also lists A).
## Use false for one-way roads, true for ordinary two-way roads.
@export var bidirectional: bool = true

var _id_by_node: Dictionary = {}

func _ready() -> void:
	set_process(Engine.is_editor_hint())
	queue_redraw()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	var nodes := _get_path_nodes()

	# Edges under nodes so the dots read cleanly at junctions.
	for node in nodes:
		var node_pos := to_local(node.global_position)
		for path in node.connections:
			var other := node.get_node_or_null(path) as PathNode2D
			if other:
				draw_line(node_pos, to_local(other.global_position), edge_color, edge_width)

	for node in nodes:
		draw_circle(to_local(node.global_position), node_radius, node_color)

func _get_path_nodes(type: PathNode2D.NodeType = PathNode2D.NodeType.NULL) -> Array[PathNode2D]:
	var result: Array[PathNode2D] = []
	for node in find_children("*", "PathNode2D", true, false):
		if !type or node.node_type ==type:
			result.append(node as PathNode2D)
	return result

## Bakes the current node/edge layout into a real AStar2D. Call this once
## at runtime (e.g. level _ready), keep the result, and reuse it —
## don't rebuild every frame.
func build_astar() -> AStar2D:
	var astar := AStar2D.new()
	var nodes := _get_path_nodes()

	_id_by_node.clear()
	for i in nodes.size():
		_id_by_node[nodes[i]] = i
		astar.add_point(i, nodes[i].global_position)

	for node in nodes:
		var from_id: int = _id_by_node[node]
		for path in node.connections:
			var other := node.get_node_or_null(path) as PathNode2D
			if other and _id_by_node.has(other):
				var to_id: int = _id_by_node[other]
				astar.connect_points(from_id, to_id, bidirectional)

	return astar

## Look up the AStar2D point id for a node, after build_astar() has run.
func get_id_for(node: PathNode2D) -> int:
	return _id_by_node.get(node, -1)

## Returns the PathNode2D whose global_position is nearest world_pos,
## or null if this graph has no PathNode2D children.
func find_closest_point(world_pos: Vector2) -> PathNode2D:
	var closest: PathNode2D = null
	var closest_dist := INF
	for node in _get_path_nodes():
		var dist := node.global_position.distance_squared_to(world_pos)
		if dist < closest_dist:
			closest_dist = dist
			closest = node
	return closest

## Returns the PathNode2D whose global_position is nearest world_pos,
## that is a POI
func find_closest_node_of_type(world_pos: Vector2, type: PathNode2D.NodeType) -> PathNode2D:
	var closest: PathNode2D = null
	var closest_dist := INF
	for node in _get_path_nodes():
		# Only look for matching node types
		if !node.node_type == type: continue
		var dist := node.global_position.distance_squared_to(world_pos)
		if dist < closest_dist:
			closest_dist = dist
			closest = node
	return closest
