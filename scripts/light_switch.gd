extends Node3D

@export var room_light_path := NodePath("../roomLight")

@onready var click_sound: AudioStreamPlayer3D = $ClickSound


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
	click_sound.play()


func _get_room_light() -> Light3D:
	return get_node_or_null(room_light_path) as Light3D
