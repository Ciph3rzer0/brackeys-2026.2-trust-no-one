#AI
@tool
class_name PathNode2D
extends Node2D
## A single vertex in an A* road graph. Position it with the normal 2D
## move gizmo; drag other PathNode2D nodes from the Scene tree into
## `connections` below to link them.

## Other PathNode2D nodes this one connects to. Direction matters if
## AStarGraph2D.bidirectional is false (see that node for one-way roads).
@export var connections: Array[NodePath] = []
