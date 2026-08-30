class_name VehicleSightingsTableView
extends PanelContainer

var _rows: Array[VehicleSightingsRowView] = []

func _ready() -> void:
	if GameManager.database:
		_connect_to_database()
		_on_database_refreshed()
	else:
		GameManager.database_loaded.connect(_on_database_loaded, CONNECT_ONE_SHOT)


func _on_database_loaded() -> void:
	_connect_to_database()
	_on_database_refreshed()


func _connect_to_database() -> void:
	if !GameManager.database.data_refreshed.is_connected(_on_database_refreshed):
		GameManager.database.data_refreshed.connect(_on_database_refreshed)


func _on_database_refreshed() -> void:
	set_table_items(GameManager.database.vehicle_sightings)

func set_table_items(rows: Array[SchemaVehicleSightings]):
	if rows.size() < _rows.size():
		clear_table_rows()
	if rows.size() == _rows.size():
		return

	for new_source_row in rows.slice(_rows.size()):
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

const DEFAULT_FROM_TIME := "00:00"
const DEFAULT_TO_TIME := "23:59"

var day_filter := ''
var from_time_filter := ''
var to_time_filter := ''

func _filter_rows():
	var start_timestamp := -1
	var end_timestamp := -1
	var start_time_of_day := -1
	var end_time_of_day := -1
	var normalized_day := day_filter.strip_edges()
	var normalized_from := from_time_filter.strip_edges()
	var normalized_to := to_time_filter.strip_edges()
	var effective_from := normalized_from if !normalized_from.is_empty() else DEFAULT_FROM_TIME
	var effective_to := normalized_to if !normalized_to.is_empty() else DEFAULT_TO_TIME

	var day_is_valid := normalized_day.is_empty() or LineEditFilter.is_valid_day_text(normalized_day)
	var from_is_valid := LineEditFilter.is_valid_time_text(effective_from)
	var to_is_valid := LineEditFilter.is_valid_time_text(effective_to)
	var time_order_is_valid := (
		from_is_valid
		and to_is_valid
		and _time_to_minutes(effective_from) <= _time_to_minutes(effective_to)
	)
	var to_precedes_from := (
		from_is_valid
		and to_is_valid
		and _time_to_minutes(effective_to) < _time_to_minutes(effective_from)
	)
	_update_time_order_validation(to_precedes_from)

	if !normalized_day.is_empty() and day_is_valid and time_order_is_valid:
		var date := "2026-08-%02d" % normalized_day.to_int()
		start_timestamp = Time.get_unix_time_from_datetime_string(
			"%sT%s:00" % [date, effective_from]
		)
		end_timestamp = Time.get_unix_time_from_datetime_string(
			"%sT%s:59" % [date, effective_to]
		)
	elif (
		normalized_day.is_empty()
		and time_order_is_valid
		and (!normalized_from.is_empty() or !normalized_to.is_empty())
	):
		start_time_of_day = _time_to_minutes(effective_from) * 60
		end_time_of_day = _time_to_minutes(effective_to) * 60 + 59
		
	#remaining filters
	for row in _rows:
		if start_timestamp >= 0 and row.source_row.unix_timestamp < start_timestamp:
			row.visible = false
			continue
		if end_timestamp >= 0 and row.source_row.unix_timestamp > end_timestamp:
			row.visible = false
			continue
		if start_time_of_day >= 0:
			var row_time_of_day := _timestamp_to_seconds_since_midnight(
				row.source_row.unix_timestamp
			)
			if row_time_of_day < start_time_of_day or row_time_of_day > end_time_of_day:
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


func _time_to_minutes(time_text: String) -> int:
	return time_text.substr(0, 2).to_int() * 60 + time_text.substr(3, 2).to_int()


func _timestamp_to_seconds_since_midnight(timestamp: int) -> int:
	var datetime := Time.get_datetime_dict_from_unix_time(timestamp)
	return (
		int(datetime.get("hour", 0)) * 60 * 60
		+ int(datetime.get("minute", 0)) * 60
		+ int(datetime.get("second", 0))
	)


func _update_time_order_validation(to_precedes_from: bool) -> void:
	var to_filter_control := get_parent().get_node_or_null("ToTimeFilter") as LineEditFilter
	if !to_filter_control:
		return
	if to_precedes_from:
		to_filter_control.set_external_validation_error("To must be the same as or later than From.")
	else:
		to_filter_control.set_external_validation_error("")

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

func _on_day_filter_filter_changed(text: String) -> void:
	day_filter = text
	_filter_rows()

func _on_from_time_filter_filter_changed(text: String) -> void:
	from_time_filter = text
	_filter_rows()

func _on_to_time_filter_filter_changed(text: String) -> void:
	to_time_filter = text
	_filter_rows()
#endregion
