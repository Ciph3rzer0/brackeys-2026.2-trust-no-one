extends Control

func _ready() -> void:
	%ColorFilter.add_item('')
	%TypeFilter.add_item('')
	%FeaturesFilter.add_item('')
		
	for val in VEHICLE_COLORS:
		%ColorFilter.add_item(val)
	for val in VEHICLE_TYPES:
		%TypeFilter.add_item(val)
	for val in VEHICLE_FEATURES:
		%FeaturesFilter.add_item(val)


const VEHICLE_FEATURES = ["Jesus fish", "Dinged hood", "Ladder rack", "Sunroof", "Custom rims", "Tinted windows", "Tow hitch", "Truck nuts", "Yosemite Sam mud flap", "Roof rack", "Aftermarket exhaust", "Missing hubcap", "Bumper sticker", "Mustard stains", "Dented rear bumper", "Cracked windshield", "Honor student bumper sticker", "Scratched bumper", "Spoiler", "Flame decals", "Aluminum spoiler", "Uneven tire marks", "Banana in tailpipe", "Empty license plate holder", "Paper tag on window", "Exposed wires", "Heavy modifications", "Bullet holes"]
const VEHICLE_COLORS = ["Gray", "White", "Beige", "Gold", "Blue", "Maroon", "Green", "Silver", "Black", "Red", "Mint Green", "Tan", "Rainbow"]
const VEHICLE_TYPES = ["Van", "Station Wagon", "Sedan", "Motorcycle", "Coupe", "Aston Martin", "SUV", "Pickup Truck", "Bus", "Hatchback", "Weinermobile", "Kia Optima", "Muscle Car", "Formula 1", "Buick Skylark", "Ford F-150", "Sierra", "DeLorean"]
