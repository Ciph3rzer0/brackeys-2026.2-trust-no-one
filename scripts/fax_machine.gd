extends Node3D

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
		player.fax_held_report()
		return

	print("interacted with fax")
