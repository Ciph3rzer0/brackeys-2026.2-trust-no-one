class_name InteractableMount
extends Area3D

@export var redirect_input: SubViewport
@export var interaction_text := "press e to sit down"


func get_interaction_text(_player: Player = null) -> String:
	return interaction_text


func play_mount_sound() -> void:
	var mount_sound := get_node_or_null("MountSound") as AudioStreamPlayer3D
	if mount_sound:
		mount_sound.play()


func push_event_to_viewport(event: InputEvent) -> bool:
	if redirect_input:
		# Push the input event into the redirect viewport
		redirect_input.push_input(event, true)
		return true
	return false
