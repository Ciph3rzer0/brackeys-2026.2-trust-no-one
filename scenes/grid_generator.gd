@tool
extends Node3D
## Generates a grid array of BoxMesh instances as real child nodes.
## Editor-only: guarded by Engine.is_editor_hint(), so it's a no-op at runtime.

@export var box_count: Vector3i = Vector3i(3, 1, 3)
@export var box_size: Vector3 = Vector3(1.0, 1.0, 1.0)
@export var spacing: Vector3 = Vector3(1.5, 1.5, 1.5)
@export var box_material: Material

const PREFIX := "Box_"

@export_tool_button("Regenerate")
var regenerate_action: Callable = _generate_boxes

@export_tool_button("Clear")
var clear_action: Callable = _clear_boxes

func _generate_boxes() -> void:
	if not Engine.is_editor_hint():
		return

	_clear_boxes()

	var mesh := BoxMesh.new()
	mesh.size = box_size

	var root := get_tree().edited_scene_root
	if root == null:
		push_warning("No edited_scene_root found — save/open the scene first.")
		return

	for x in box_count.x:
		for y in box_count.y:
			for z in box_count.z:
				var inst := MeshInstance3D.new()
				inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				inst.layers = 32768 # Camera Grid
				inst.mesh = mesh
				if box_material:
					inst.set_surface_override_material(0, box_material)
				inst.name = "%s%d_%d_%d" % [PREFIX, x, y, z]
				inst.position = Vector3(x, y, z) * spacing

				add_child(inst)
				inst.owner = root  # required so it's saved with the scene

func _clear_boxes() -> void:
	if not Engine.is_editor_hint():
		return

	for child in get_children():
		if child.name.begins_with(PREFIX):
			remove_child(child)
			child.free()
