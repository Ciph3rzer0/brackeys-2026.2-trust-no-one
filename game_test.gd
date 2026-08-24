extends Control

var _database: Database

func _ready() -> void:
	_database = Database.new()
	
	assert(_database != null)
	$RmsPersonsTableView.set_table_items(_database.rms_persons)
	$VehicleSightingsTableView.set_table_items(_database.vehicle_sightings)
