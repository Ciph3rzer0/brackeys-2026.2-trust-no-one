@tool
class_name PathNode2D
extends Sprite2D

const BLACK_GRADIENT_TEXTURE_2D = preload("uid://c4cdvmetoww61")
const GREEN_GRADIENT_TEXTURE_2D = preload("uid://qlv27q81cyvk")
const ORANGE_GRADIENT_TEXTURE_2D = preload("uid://cp6p7x7g37eh6")
const PINK_GRADIENT_TEXTURE_2D = preload("uid://c3w7gfq11xjbp")
const HOME_GRADIENT_TEXTURE_2D = preload("uid://y08x8cseub27")
const WORK_GRADIENT_TEXTURE_2D = preload("uid://cmlv71m2o7jy4")

enum NodeType {
	NULL = 0,
	Intersection,
	POI,
	CityExit,
	ShadyPOI,
	Residence,
	Work,
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
			NodeType.ShadyPOI:
				texture = PINK_GRADIENT_TEXTURE_2D
			NodeType.Residence:
				texture = HOME_GRADIENT_TEXTURE_2D
			NodeType.Work:
				texture = WORK_GRADIENT_TEXTURE_2D
