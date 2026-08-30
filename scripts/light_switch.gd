extends Node3D

@export var room_light_path := NodePath("../roomLight")
@export var off_glow_color := Color(0.225, 0.6, 0.56)
@export_range(0.0, 2.0, 0.05) var off_glow_energy := 0.35

@onready var click_sound: AudioStreamPlayer3D = $ClickSound
@onready var switch_mesh: MeshInstance3D = $SwitchMesh

var _switch_material: StandardMaterial3D


func _ready() -> void:
	var source_material := switch_mesh.get_active_material(0) as StandardMaterial3D
	if source_material:
		_switch_material = source_material.duplicate() as StandardMaterial3D
		switch_mesh.set_surface_override_material(0, _switch_material)
	_update_switch_glow()


func can_interact(_player: Player) -> bool:
	return _get_room_light() != null


func get_interaction_text(_player: Player) -> String:
	var room_light := _get_room_light()
	if room_light and room_light.visible:
		return "press e to turn off the room light"
	return "press e to turn on the room light"


func interact(_player: Player = null) -> void:
	var room_light := _get_room_light()
	if !room_light:
		return

	room_light.visible = !room_light.visible
	_update_switch_glow()
	click_sound.play()


func _get_room_light() -> Light3D:
	return get_node_or_null(room_light_path) as Light3D


func _update_switch_glow() -> void:
	if !_switch_material:
		return

	var room_light := _get_room_light()
	_switch_material.emission_enabled = room_light != null and !room_light.visible
	_switch_material.emission = off_glow_color
	_switch_material.emission_energy_multiplier = off_glow_energy
