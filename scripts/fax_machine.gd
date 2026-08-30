extends Node3D

@onready var fax_sound: AudioStreamPlayer3D = $FaxSound


func get_interaction_text(player: Player) -> String:
	if player and player.has_held_report():
		var rejection_reason := player.get_fax_rejection_reason()
		if !rejection_reason.is_empty():
			return rejection_reason
		return "press e to fax report"
	return ""

func interact(player: Player = null) -> void:
	if !player:
		player = GameManager.player

	if player and player.has_held_report():
		if player.fax_held_report():
			fax_sound.play()
		return

	print("interacted with fax")
