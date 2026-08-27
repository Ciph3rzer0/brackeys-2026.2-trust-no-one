class_name VehicleSightingsTableView
extends PanelContainer

var _rows: Array[VehicleSightingsRowView]

func _ready() -> void:
	GameManager.database.data_refreshed.connect( func():
		set_table_items(GameManager.database.vehicle_sightings)
	)

func set_table_items(rows: Array[SchemaVehicleSightings]):
	clear_table_rows()
	for new_source_row in rows:
		var new_table_row: VehicleSightingsRowView = %TableRow.duplicate()
		new_table_row.set_source_row(new_source_row)
		new_table_row.visible = true
		_rows.append(new_table_row)
		%TableBody.add_child(new_table_row)

func clear_table_rows():
	print("clearing row")
	for row in _rows:
		row.queue_free()
	_rows.clear()

func _on_plate_filter_filter_changed(text: String) -> void:
	for row in _rows:
		row.visible = !text or text.is_subsequence_ofn(row.source_row.vehicle_plate)
