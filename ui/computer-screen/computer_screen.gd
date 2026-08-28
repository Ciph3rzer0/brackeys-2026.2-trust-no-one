extends Control

func _ready() -> void:
	%ColorFilter.add_item('')
	%TypeFilter.add_item('')
	%FeaturesFilter.add_item('')
		
	for val in MockDataFactory.VEHICLE_COLORS:
		%ColorFilter.add_item(val)
	for val in MockDataFactory.VEHICLE_TYPES:
		%TypeFilter.add_item(val)
	for val in MockDataFactory.VEHICLE_FEATURES:
		%FeaturesFilter.add_item(val)
