extends Node3D

@export var rules_menu_path := NodePath("../TownRulesMenu")

@onready var click_sound: AudioStreamPlayer3D = $ClickSound


func can_interact(_player: Player) -> bool:
	return _get_rules_menu() != null


func get_interaction_text(_player: Player) -> String:
	var rules_menu := _get_rules_menu()
	if rules_menu and rules_menu.visible:
		return "press e to close town rules"
	return "press e to review town rules"


func interact(player: Player = null) -> void:
	var rules_menu := _get_rules_menu()
	if !rules_menu:
		return

	click_sound.play()
	rules_menu.call("toggle_menu", player)


func _get_rules_menu() -> CanvasLayer:
	return get_node_or_null(rules_menu_path) as CanvasLayer
