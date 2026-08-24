class_name TableUI
extends PanelContainer

var _rows: Array[RmsPersonsRowView]

func set_table_items(rows: Array[SchemaRmsPersons]):
	for new_source_row in rows:
		var new_table_row: RmsPersonsRowView = %TableRow.duplicate()
		new_table_row.set_source_row(new_source_row)
		new_table_row.visible = true
		_rows.append(new_table_row)
		%TableBody.add_child(new_table_row)

func _on_plate_filter_filter_changed(text: String) -> void:
	for row in _rows:
		row.visible = !text or text.is_subsequence_ofn(row.source_row.car_plate)
