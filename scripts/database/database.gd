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
	var sightings := CSVHelper.load_all_data()
	vehicle_sightings = sightings
	
	# var unique_objects := {}
	
	#var features = flatten_shallow(sightings.map(func(s): return s.vehicle_features))
	#
	#for feat in features:
		#unique_objects[feat] = true
	#
	#print(unique_objects.keys())
	
	#var colors = sightings.map(func(s): return s.vehicle_color)
	#unique_objects = {}
	#
	#for color in colors:
		#unique_objects[color] = true
	#
	#print(unique_objects.keys())
	#
	#var types = sightings.map(func(s): return s.vehicle_type)
	#unique_objects = {}
	#
	#for type in types:
		#unique_objects[type] = true
	#
	#print(unique_objects.keys())

## Flattens exactly one level of nested arrays
func flatten_shallow(nested_array: Array) -> Array:
	var flat_array = []
	for item in nested_array:
		if item is Array:
			flat_array.append_array(item)
		else:
			flat_array.push_back(item)
	return flat_array
