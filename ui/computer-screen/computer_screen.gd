extends Control

func _ready() -> void:
	_set_viewport_update_mode(SubViewport.UPDATE_ONCE)


func _on_computer_mounted() -> void:
	_set_viewport_update_mode(SubViewport.UPDATE_ALWAYS)
	$VehicleSightingsTableView.activate()


func _on_computer_dismounted() -> void:
	_set_viewport_update_mode(SubViewport.UPDATE_ONCE)


func _set_viewport_update_mode(update_mode: int) -> void:
	var computer_viewport := get_viewport() as SubViewport
	if computer_viewport:
		computer_viewport.render_target_update_mode = update_mode


func _on_vehicle_sightings_table_view_options_filters_updated(colors: Array[String], types: Array[String], features: Array[String]) -> void:
	%ColorFilter.clear()
	%TypeFilter.clear()
	%FeaturesFilter.clear()
	
	%ColorFilter.add_item("")
	%TypeFilter.add_item("")
	%FeaturesFilter.add_item("")
	
	for val in colors:
		if val.is_empty(): continue
		print("color, '", val, "'")
		%ColorFilter.add_item(val)
	for val in types:
		if val.is_empty(): continue
		print("type, '", val, "'")
		%TypeFilter.add_item(val)
	for val in features:
		if val.is_empty(): continue
		print("feature, '", val, "'")
		%FeaturesFilter.add_item(val)
