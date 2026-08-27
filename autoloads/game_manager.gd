extends Node

var player: Player
var database: Database

func setplayer(_player: Player):
	assert(!player)
	player = _player

func _ready() -> void:
	database = Database.new()
	
	#assert(database != null)
	#$RmsPersonsTableView.set_table_items(database.rms_persons)
	#$VehicleSightingsTableView.set_table_items(database.vehicle_sightings)

	if player:
		print("PLAYER IS ", player.name)
	
	await get_tree().process_frame
	database.refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Q:
			QuestSystem.assign_new_quest()
			get_viewport().set_input_as_handled()
