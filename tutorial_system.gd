extends Node

@export var outline_material: StandardMaterial3D
@onready var outline_material_next := (outline_material.next_pass as StandardMaterial3D)

@export var pulse_speed: float = 4.0
@export var base_grow: float = 0.05
@export var pulse_intensity: float = 0.03

@export var tutorial_objects: Array[Node3D]
var _index := 0
var _current_object: Node3D
var _current_mesh: MeshInstance3D
var _time := 0.0


func _ready() -> void:
	assert(tutorial_objects.size() > 0)
	for object in tutorial_objects:
		assert(object.has_signal(&'was_interacted_with'))
	
	next_tutorial_item(0)


func next_tutorial_item(index: int = _index + 1):
	_index = index
	
	# Remove old mesh
	if _current_mesh:
		_current_mesh.material_overlay = null
	
	# Stop at the end of the list
	if index >= tutorial_objects.size(): return
	
	_current_object = tutorial_objects[_index]
	
	_current_object.was_interacted_with.connect(next_tutorial_item, ConnectFlags.CONNECT_ONE_SHOT)
	_current_mesh = _find_child_mesh(_current_object)
	assert(_current_mesh != null)
	_current_mesh.material_overlay = outline_material


func _find_child_mesh(node: Node3D) -> Node3D:
	for child: Node3D in node.get_children():
		if child is MeshInstance3D:
			return child
		elif child.get_child_count() > 0:
			return _find_child_mesh(child)
	
	return null


func _process(delta: float) -> void:
	if outline_material_next:
		_time += delta
		# Calculate sine wave oscillating between -1 and 1
		var wave = sin(_time * pulse_speed) 
		
		# Calculate new thickness
		var current_grow = base_grow + (wave * pulse_intensity)
		
		# Update the built-in Grow property of the material
		outline_material_next.set("grow_amount", current_grow)


func tutorial_object_was_interacted_with():
	next_tutorial_item()
	
