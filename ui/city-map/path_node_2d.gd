@tool
class_name PathNode2D
extends Sprite2D

const BLACK_GRADIENT_TEXTURE_2D = preload("uid://c4cdvmetoww61")
const GREEN_GRADIENT_TEXTURE_2D = preload("uid://qlv27q81cyvk")
const ORANGE_GRADIENT_TEXTURE_2D = preload("uid://cp6p7x7g37eh6")

enum NodeType {
	Intersection,
	POI,
	CityExit,
}

@export var connections: Array[NodePath] = []
@export var node_type: NodeType:
	set(val):
		node_type = val
		match node_type:
			NodeType.Intersection:
				texture = BLACK_GRADIENT_TEXTURE_2D
			NodeType.POI:
				texture = GREEN_GRADIENT_TEXTURE_2D
			NodeType.CityExit:
				texture = ORANGE_GRADIENT_TEXTURE_2D
