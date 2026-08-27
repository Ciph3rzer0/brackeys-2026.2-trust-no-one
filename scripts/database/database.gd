class_name Database

signal data_refreshed
func refresh():
	print("DB Refreshing Signal")
	data_refreshed.emit()

var rms_persons: Array[SchemaRmsPersons]
var rms_vehicles: Array[SchemaRmsVehicles]
var vehicle_sightings: Array[SchemaVehicleSightings]

func _init():
	seed(7)
	rms_persons = MockDataFactory.generate_rows(100)
	rms_vehicles = MockDataFactory.generate_vehicles(100)
	print(rms_vehicles)
	vehicle_sightings = MockDataFactory.generate_vehicle_sightings(2, rms_persons)
	refresh()
