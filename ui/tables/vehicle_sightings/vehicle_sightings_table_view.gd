class_name VehicleSightingsTableView
extends PanelContainer

var _rows: Array[VehicleSightingsRowView]

func _ready() -> void:
	GameManager.database.data_refreshed.connect( func():
		set_table_items(GameManager.database.vehicle_sightings)
	)

func set_table_items(rows: Array[SchemaVehicleSightings]):
	#clear_table_rows()
	var new_count = rows.size() - _rows.size()
	
	for new_source_row in rows.slice(-new_count):
		var new_table_row: VehicleSightingsRowView = %TableRow.duplicate()
		new_table_row.set_source_row(new_source_row)
		new_table_row.visible = true
		_rows.append(new_table_row)
		%TableBody.add_child(new_table_row)

func clear_table_rows():
	for row in _rows:
		row.queue_free()
	_rows.clear()

var plate_filter := ''
var camera_filter := ''
var color_filter := ''
var type_filter := ''
var features_filter := ''

var date_filter := ''
var time_filter := ''
var range_filter := ''

func _filter_rows():
	var start := -1
	var end := -1
	
	if date_filter.length() <= 2 and date_filter.is_valid_int():
		var date = "2026-08-" + date_filter
		var time_regex = RegEx.new()
		var range_regex = RegEx.new()
		
		# Double backslash is required so GDScript passes '\d' to the engine
		time_regex.compile("(\\d{1,2}):(\\d{2})") 
		var time_r := time_regex.search(time_filter)
		if time_r:
			var hour = time_r.get_string(1).pad_zeros(2)
			var minute  = time_r.get_string(2)
			date += "T"+hour+":"+minute+":00"
		
		start = Time.get_unix_time_from_datetime_string(date)
				
		# Determine range
		range_regex.compile("([+-]?)(\\d{1,2})([hm])") 
		var range_r := range_regex.search(range_filter)
		if range_r:
			# Individual capture groups
			var sign_part = range_r.get_string(1)  # Yields "-"
			var num_part  = range_r.get_string(2)  # Yields "45"
			var unit_part = range_r.get_string(3)  # Yields "m"
			
			# Example use case: Convert text to a clean integer
			var second_range = num_part.to_int() * 60
			
			if unit_part == "h":
				second_range *= 60
			
			end = start + second_range
		
	#remaining filters
	for row in _rows:
		if row.source_row.unix_timestamp < start:
			row.visible = false
			continue
		if end > 0 and row.source_row.unix_timestamp > end:
			row.visible = false
			continue
		
		if plate_filter.length() and !plate_filter.is_subsequence_ofn(row.source_row.vehicle_plate):
			row.visible = false
			continue
			
		if camera_filter.length() and !camera_filter.is_subsequence_ofn(row.source_row.camera_id):
			row.visible = false
			continue
			
		if color_filter.length() and !color_filter.is_subsequence_ofn(row.source_row.vehicle_color):
			row.visible = false
			continue
			
		if type_filter.length() and !type_filter.is_subsequence_ofn(row.source_row.vehicle_type):
			row.visible = false
			continue
			
		if features_filter.length() and !features_filter.is_subsequence_ofn(", ".join(row.source_row.vehicle_features)):
			row.visible = false
			continue
		
		
		if features_filter.length() and !features_filter.is_subsequence_ofn(", ".join(row.source_row.vehicle_features)):
			row.visible = false
			continue
		
		row.visible = true

#region Filter signal hooks
func _on_plate_filter_filter_changed(text: String) -> void:
	plate_filter = text
	_filter_rows()

func _on_camera_filter_filter_changed(text: String) -> void:
	camera_filter = text
	_filter_rows()

func _on_color_filter_filter_changed(text: String) -> void:
	color_filter = text
	_filter_rows()

func _on_type_filter_filter_changed(text: String) -> void:
	type_filter = text
	_filter_rows()

func _on_features_filter_filter_changed(text: String) -> void:
	features_filter = text
	_filter_rows()

func _on_date_filter_filter_changed(text: String) -> void:
	date_filter = text
	_filter_rows()

func _on_time_filter_filter_changed(text: String) -> void:
	time_filter = text
	_filter_rows()

func _on_time_range_filter_filter_changed(text: String) -> void:
	range_filter = text
	_filter_rows()
#endregion
