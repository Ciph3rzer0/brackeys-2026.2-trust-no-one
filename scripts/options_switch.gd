extends Node3D

@export var options_menu_path := NodePath("../AudioOptionsMenu")

@onready var click_sound: AudioStreamPlayer3D = $ClickSound


func can_interact(_player: Player) -> bool:
	return _get_options_menu() != null


func get_interaction_text(_player: Player) -> String:
	var options_menu := _get_options_menu()
	if options_menu and options_menu.visible:
		return "press e to close audio options"
	return "press e to open audio options"


func interact(player: Player = null) -> void:
	var options_menu := _get_options_menu()
	if !options_menu:
		return

	click_sound.play()
	options_menu.call("toggle_menu", player)


func _get_options_menu() -> CanvasLayer:
	return get_node_or_null(options_menu_path) as CanvasLayer
