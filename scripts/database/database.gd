class_name Database

signal data_refreshed
func refresh():
	print("DB Refreshing Signal")
	data_refreshed.emit()

var rms_persons: Array[SchemaRmsPersons]
var vehicle_sightings: Array[SchemaVehicleSightings]

func _init():
	seed(7)
	rms_persons = MockDataFactory.generate_rows(100)
	vehicle_sightings = MockDataFactory.generate_vehicle_sightings(2, rms_persons)
	refresh()
