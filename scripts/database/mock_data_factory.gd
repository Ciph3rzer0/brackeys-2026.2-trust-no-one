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
	"Black", "White", "Silver", "Gray", "Red", "Blue", "Green", "Beige", "Gold", "Maroon"
]

const VEHICLE_TYPES: Array[String] = [
	"Sedan", "SUV", "Pickup Truck", "Van", "Coupe", "Hatchback", "Motorcycle", "Bus"
]

const VEHICLE_FEATURES: Array[String] = [
	"Tinted windows", "Roof rack", "Spoiler", "Cracked windshield", "Dented rear bumper",
	"Custom rims", "Bumper sticker", "Missing hubcap", "Tow hitch", "Ladder rack",
	"Sunroof", "Aftermarket exhaust"
]

static func generate_vehicle_sightings(count: int = 100, vehicles: Array[SchemaRmsVehicles] = []) -> Array[SchemaVehicleSightings]:
	count = clampi(count, 0, 1000)
	var sightings: Array[SchemaVehicleSightings] = []
	for i in range(count):
		sightings.append(generate_vehicle_sighting(i + 1, vehicles))
	return sightings

static func generate_vehicle_sighting(sighting_id: int = 1, vehicles: Array[SchemaRmsVehicles] = []) -> SchemaVehicleSightings:
	var sighting := SchemaVehicleSightings.new()
	sighting.sighting_id = sighting_id

	var vehicle: SchemaRmsVehicles = vehicles.pick_random() if not vehicles.is_empty() else generate_vehicle()

	sighting.vehicle_plate = vehicle.plate
	var now := Time.get_unix_time_from_system()
	sighting.unix_timestamp = int(now - randi_range(0, SIGHTING_LOOKBACK_SECONDS))
	sighting.camera_id = "CAM-%03d" % randi_range(1, 40)
	sighting.vehicle_color = vehicle.color
	sighting.vehicle_type = vehicle.type
	sighting.vehicle_features = vehicle.features
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

## Add these to MockDataFactory alongside the existing const arrays and
## generate_x()/generate_xs() pairs.


const PLATE_LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const PLATE_DIGITS := "0123456789"


static func generate_vehicle() -> SchemaRmsVehicles:
	var vehicle := SchemaRmsVehicles.new()
	vehicle.plate = _generate_plate()
	vehicle.color = VEHICLE_COLORS.pick_random()
	vehicle.type = VEHICLE_TYPES.pick_random()

	var shuffled := VEHICLE_FEATURES.duplicate()
	shuffled.shuffle()
	var feature_count := randi_range(0, 2)  # most vehicles have 0-2 distinguishing features
	vehicle.features = shuffled.slice(0, feature_count)

	return vehicle

static func generate_vehicles(count: int) -> Array[SchemaRmsVehicles]:
	var vehicles: Array[SchemaRmsVehicles] = []
	for i in count:
		vehicles.append(generate_vehicle())
	return vehicles
