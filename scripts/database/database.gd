class_name Database

signal data_refreshed
func refresh():
	print("DB Refreshing Signal")
	data_refreshed.emit()

var rms_persons: Array[SchemaRmsPersons] = []
var rms_vehicles: Array[SchemaRmsVehicles] = []
var vehicle_sightings: Array[SchemaVehicleSightings] = []

func _init():
	# As long as the seed is the same, it will generate the vehicle list the same
	seed(7)
	rms_vehicles = MockDataFactory.generate_vehicles(100)
	
	#rms_persons not used
	#rms_persons = MockDataFactory.generate_rows(100)
	
	# Sightings are loaded asynchronously after the start menu is visible.


func load_from_csv_async(scene_tree: SceneTree) -> void:
	vehicle_sightings = await CSVHelper.load_all_data_async(scene_tree)
	refresh()


func has_vehicle_plate(plate: String) -> bool:
	var normalized_plate := plate.strip_edges().to_upper()
	if normalized_plate.is_empty():
		return false

	for sighting in vehicle_sightings:
		if sighting.vehicle_plate.strip_edges().to_upper() == normalized_plate:
			return true

	return false
