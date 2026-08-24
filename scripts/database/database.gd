class_name Database

var rms_persons: Array[SchemaRmsPersons]
var vehicle_sightings: Array[SchemaVehicleSightings]

func _init():
	seed(7)
	rms_persons = MockDataFactory.generate_rows(100)
	vehicle_sightings = MockDataFactory.generate_vehicle_sightings(100, rms_persons)
