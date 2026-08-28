extends Node3D

func get_interaction_text(player: Player) -> String:
	if player and player.has_held_report():
		return "press e to fax report"
	return "press e to interact"

func interact(player: Player = null) -> void:
	if !player:
		player = GameManager.player

	if player and player.fax_held_report():
		return

	print("interacted with fax")
