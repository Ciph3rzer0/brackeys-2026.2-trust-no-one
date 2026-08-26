class_name InteractableMount
extends Area3D

@export var redirect_input: SubViewport

func push_keypress_to_viewport(event: InputEventKey) -> bool:
	if redirect_input:
		# Push the input event into the redirect viewport
		redirect_input.push_input(event, true)
		return true
	return false
