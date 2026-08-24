class_name TableUI
extends PanelContainer

var _database: Database
var _rows: Array[TableRow]

func _ready() -> void:
	_database = Database.new()
	
	assert(_database != null)
	set_table_items(_database)

func set_table_items(database: Database):
	_database = database
	
	for new_source_row in database.rows:
		var new_table_row: TableRow = %TableRow.duplicate()
		new_table_row.set_source_row(new_source_row)
		new_table_row.visible = true
		_rows.append(new_table_row)
		%TableBody.add_child(new_table_row)


func _on_plate_filter_filter_changed(text: String) -> void:
	for row in _rows:
		row.visible = !text or row.source_row.car_plate.containsn(text)
