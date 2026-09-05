class_name VehicleSightingsTableView
extends PanelContainer

signal options_filters_updated(colors: Array[String], types: Array[String], features: Array[String])

const PAGE_SIZE := 18
const DEFAULT_FROM_TIME := "00:00"
const DEFAULT_TO_TIME := "23:59"

var _rows: Array[VehicleSightingsRowView] = []
var _source_rows: Array[SchemaVehicleSightings] = []
var _filtered_rows: Array[SchemaVehicleSightings] = []
var _current_page := 0
var _is_active := false

var plate_filter := ''
var camera_filter := ''
var color_filter := ''
var type_filter := ''
var features_filter := ''
var day_filter := ''
var from_time_filter := ''
var to_time_filter := ''


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
	set_table_options(GameManager.database.vehicle_sightings)

func set_table_options(rows: Array[SchemaVehicleSightings]) -> void:
	var colors_dict: Dictionary[String, bool] = {}
	var types_dict: Dictionary[String, bool] = {}
	var features_dict: Dictionary[String, bool] = {}
	
	colors_dict[""] = true
	types_dict[""] = true
	features_dict[""] = true
	
	for row in rows:
		colors_dict[row.vehicle_color] = true
		types_dict[row.vehicle_type] = true
		for feature in row.vehicle_features:
			features_dict[feature] = true
	
	var colors = colors_dict.keys(); colors.sort()
	var types = types_dict.keys(); types.sort()
	var features = features_dict.keys(); features.sort()
	
	options_filters_updated.emit(colors, types, features)

func activate() -> void:
	if _is_active:
		return

	_is_active = true
	_ensure_row_pool()
	_filter_rows()


func set_table_items(rows: Array[SchemaVehicleSightings]) -> void:
	_source_rows.clear()
	_source_rows.append_array(rows)
	if _is_active:
		_filter_rows()
	else:
		_update_pagination_controls()


func _ensure_row_pool() -> void:
	if !_rows.is_empty():
		return

	for index in range(PAGE_SIZE):
		var new_table_row: VehicleSightingsRowView = %TableRow.duplicate()
		new_table_row.name = "PooledTableRow%d" % index
		new_table_row.visible = false
		_rows.append(new_table_row)
		%TableBody.add_child(new_table_row)


func _render_current_page() -> void:
	if !_is_active:
		return

	var page_count := _get_page_count()
	_current_page = clampi(_current_page, 0, page_count - 1)
	var start_index := _current_page * PAGE_SIZE
	for index in range(_rows.size()):
		var source_index := start_index + index
		var table_row := _rows[index]
		if source_index < _filtered_rows.size():
			table_row.set_source_row(_filtered_rows[source_index])
			table_row.visible = true
		else:
			table_row.visible = false

	%ScrollContainer.scroll_vertical = 0
	_update_pagination_controls()


func _get_page_count() -> int:
	return maxi(1, ceili(float(_filtered_rows.size()) / PAGE_SIZE))


func _update_pagination_controls() -> void:
	var result_count := _filtered_rows.size() if _is_active else _source_rows.size()
	var page_count := maxi(1, ceili(float(result_count) / PAGE_SIZE))
	_current_page = clampi(_current_page, 0, page_count - 1)
	%PreviousPageButton.disabled = !_is_active or result_count == 0 or _current_page == 0
	%NextPageButton.disabled = (
		!_is_active
		or result_count == 0
		or _current_page >= page_count - 1
	)

	if !_is_active:
		%PageLabel.text = "Open computer to load records"
	elif result_count == 0:
		%PageLabel.text = "No matching records"
	else:
		var first_result := _current_page * PAGE_SIZE + 1
		var last_result := mini(first_result + PAGE_SIZE - 1, result_count)
		%PageLabel.text = "%d-%d of %d" % [first_result, last_result, result_count]


func _on_previous_page_button_pressed() -> void:
	if _current_page <= 0:
		return
	_current_page -= 1
	_render_current_page()


func _on_next_page_button_pressed() -> void:
	if _current_page >= _get_page_count() - 1:
		return
	_current_page += 1
	_render_current_page()

func clear_table_rows():
	for row in _rows:
		row.queue_free()
	_rows.clear()

func _filter_rows():
	var start_timestamp := -1
	var end_timestamp := -1
	var start_time_of_day := -1
	var end_time_of_day := -1
	var normalized_day := day_filter.strip_edges()
	var normalized_from := LineEditFilter.normalize_time_text(from_time_filter)
	var normalized_to := LineEditFilter.normalize_time_text(to_time_filter)
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
		
	_filtered_rows.clear()
	for source_row in _source_rows:
		if start_timestamp >= 0 and source_row.unix_timestamp < start_timestamp:
			continue
		if end_timestamp >= 0 and source_row.unix_timestamp > end_timestamp:
			continue
		if start_time_of_day >= 0:
			var row_time_of_day := _timestamp_to_seconds_since_midnight(
				source_row.unix_timestamp
			)
			if row_time_of_day < start_time_of_day or row_time_of_day > end_time_of_day:
				continue
		
		if plate_filter.length() and !plate_filter.is_subsequence_ofn(source_row.vehicle_plate):
			continue
			
		if camera_filter.length() and !camera_filter.is_subsequence_ofn(source_row.camera_id):
			continue
			
		if color_filter.length() and !color_filter.is_subsequence_ofn(source_row.vehicle_color):
			continue
			
		if type_filter.length() and !type_filter.is_subsequence_ofn(source_row.vehicle_type):
			continue
			
		if features_filter.length() and !features_filter.is_subsequence_ofn(", ".join(source_row.vehicle_features)):
			continue

		_filtered_rows.append(source_row)

	_current_page = 0
	_render_current_page()


func _time_to_minutes(time_text: String) -> int:
	var normalized := LineEditFilter.normalize_time_text(time_text)
	return normalized.substr(0, 2).to_int() * 60 + normalized.substr(3, 2).to_int()


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
