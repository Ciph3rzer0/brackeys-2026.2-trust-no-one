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

func _filter_rows():
	for row in _rows:
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
		
		row.visible = true

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
