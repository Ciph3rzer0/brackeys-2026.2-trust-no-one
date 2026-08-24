class_name MockDataFactory
## AI CLASS

const SIGHTING_LOOKBACK_SECONDS := 60 * 60 * 24 * 90 # past 90 days

const FIRST_NAMES: Array[String] = [
	"James", "Mary", "Robert", "Patricia", "John", "Jennifer", "Michael", "Linda",
	"William", "Elizabeth", "David", "Barbara", "Richard", "Susan", "Joseph", "Jessica",
	"Thomas", "Sarah", "Charles", "Karen", "Daniel", "Nancy", "Matthew", "Lisa",
	"Anthony", "Betty", "Mark", "Margaret", "Donald", "Sandra"
]

const LAST_NAMES: Array[String] = [
	"Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
	"Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
	"Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson",
	"White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson"
]

const CAR_MAKES: Dictionary = {
	"Toyota": ["Camry", "Corolla", "RAV4", "Highlander", "Tacoma"],
	"Honda": ["Civic", "Accord", "CR-V", "Pilot", "Odyssey"],
	"Ford": ["F-150", "Escape", "Explorer", "Focus", "Mustang"],
	"Chevrolet": ["Silverado", "Malibu", "Equinox", "Tahoe", "Camaro"],
	"Tesla": ["Model 3", "Model Y", "Model S", "Model X"],
	"Subaru": ["Outback", "Forester", "Impreza", "Crosstrek"],
}

const STREET_NAMES: Array[String] = [
	"Maple St", "Oak Ave", "Cedar Ln", "Elm St", "Pine Rd", "Washington Ave",
	"Lake Dr", "Hill St", "Sunset Blvd", "River Rd", "Church St", "Park Ave"
]

const CITIES_STATES: Array[Array] = [
	["Philadelphia", "PA"], ["Austin", "TX"], ["Portland", "OR"], ["Denver", "CO"],
	["Nashville", "TN"], ["Columbus", "OH"], ["Raleigh", "NC"], ["Boise", "ID"],
]

const VEHICLE_COLORS: Array[String] = [
	"Black", "White", "Silver", "Gray", "Red", "Blue", "Green", "Tan", "Yellow", "Maroon"
]

const VEHICLE_TYPES: Array[String] = [
	"Sedan", "SUV", "Pickup Truck", "Coupe", "Hatchback", "Minivan", "Motorcycle", "Van"
]

const VEHICLE_FEATURES: Array[String] = [
	"Tinted windows", "Roof rack", "Tow hitch", "Rear spoiler", "Bumper sticker",
	"Dent - rear bumper", "Cracked windshield", "Aftermarket rims", "Ladder rack",
	"Missing hubcap", "Commercial decal", "Bike rack", "Fog lights", "Sunroof"
]

static func generate_vehicle_sightings(count: int = 100, persons: Array[SchemaRmsPersons] = []) -> Array[SchemaVehicleSightings]:
	count = clampi(count, 0, 1000)
	var sightings: Array[SchemaVehicleSightings] = []
	for i in range(count):
		sightings.append(generate_vehicle_sighting(i + 1, persons))
	return sightings

static func generate_vehicle_sighting(sighting_id: int = 1, persons: Array[SchemaRmsPersons] = []) -> SchemaVehicleSightings:
	var sighting := SchemaVehicleSightings.new()
	sighting.sighting_id = sighting_id
	sighting.car_plate = persons.pick_random().car_plate if not persons.is_empty() else _generate_plate()

	var now := Time.get_unix_time_from_system()
	var past_unix := now - randi_range(0, SIGHTING_LOOKBACK_SECONDS)
	sighting.timestamp = Time.get_datetime_string_from_unix_time(int(past_unix), true)

	sighting.camera_id = "CAM-%03d" % randi_range(1, 40)
	sighting.vehicle_color = VEHICLE_COLORS.pick_random()
	sighting.vehicle_type = VEHICLE_TYPES.pick_random()
	sighting.vehicle_features = _generate_features()

	return sighting

static func generate_rows(count: int = 100) -> Array[SchemaRmsPersons]:
	count = clampi(count, 0, 100)
	var rows: Array[SchemaRmsPersons] = []
	for i in range(count):
		rows.append(generate_row())
	return rows

static func _generate_features() -> Array[String]:
	var pool := VEHICLE_FEATURES.duplicate()
	pool.shuffle()
	var feature_count := randi_range(0, 3)
	var result: Array[String] = []
	for i in range(feature_count):
		result.append(pool[i])
	return result


static func generate_row() -> SchemaRmsPersons:
	var row := SchemaRmsPersons.new()
	row.first_name = FIRST_NAMES.pick_random()
	row.last_name = LAST_NAMES.pick_random()

	var make: String = CAR_MAKES.keys().pick_random()
	row.car_make = make
	row.car_model = CAR_MAKES[make].pick_random()
	row.car_plate = _generate_plate()

	row.home_address = _generate_address()
	return row


static func _generate_plate() -> String:
	var letters := ""
	for i in range(3):
		letters += char(randi_range(65, 90)) # A-Z
	return "%s-%d" % [letters, randi_range(1000, 9999)]


static func _generate_address() -> String:
	var house_num := randi_range(100, 9999)
	var street: String = STREET_NAMES.pick_random()
	var city_state: Array = CITIES_STATES.pick_random()
	var zip_code := randi_range(10000, 99999)
	return "%d %s, %s, %s %d" % [house_num, street, city_state[0], city_state[1], zip_code]
