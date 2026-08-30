class_name Database

signal data_refreshed
func refresh():
	print("DB Refreshing Signal")
	data_refreshed.emit()

var rms_persons: Array[SchemaRmsPersons]
var rms_vehicles: Array[SchemaRmsVehicles]
var vehicle_sightings: Array[SchemaVehicleSightings]

func _init():
	# As long as the seed is the same, it will generate the vehicle list the same
	seed(7)
	rms_vehicles = MockDataFactory.generate_vehicles(100)
	
	#rms_persons not used
	#rms_persons = MockDataFactory.generate_rows(100)
	
	# Sightings not generated randomly anymore
	#vehicle_sightings = MockDataFactory.generate_vehicle_sightings(4, rms_vehicles)
	load_from_csv()
	refresh()

func load_from_csv():
	var sightings = CSVHelper.load_all_data()
	vehicle_sightings = sightings


func has_vehicle_plate(plate: String) -> bool:
	var normalized_plate := plate.strip_edges().to_upper()
	if normalized_plate.is_empty():
		return false

	for sighting in vehicle_sightings:
		if sighting.vehicle_plate.strip_edges().to_upper() == normalized_plate:
			return true

	return false
