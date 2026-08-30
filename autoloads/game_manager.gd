extends Node

signal database_loaded

var player: Player
var database: Database
var is_database_ready := false
var _first_day_notes_requested := true


func request_first_day_notes() -> void:
	_first_day_notes_requested = true


func consume_first_day_notes_request() -> bool:
	var was_requested := _first_day_notes_requested
	_first_day_notes_requested = false
	return was_requested

func set_player(_player: Player):
	assert(!is_instance_valid(player) or player == _player)
	player = _player


func clear_player(_player: Player) -> void:
	if player == _player:
		player = null

func spawn_crime_report(quest: Quest = null) -> CrimeReport3D:
	var corkboard := get_tree().get_first_node_in_group("CrimeReportCorkboard") as Corkboard
	if !corkboard:
		push_warning("Cannot spawn a crime report: no corkboard is in the current scene.")
		return null
	return corkboard.spawn_report(quest)

func _ready() -> void:
	database = Database.new()
	_load_database_after_first_draw()


func _load_database_after_first_draw() -> void:
	# Let the initial scene reach the screen before doing any CSV parsing.
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	await database.load_from_csv_async(get_tree())
	is_database_ready = true
	database_loaded.emit()
