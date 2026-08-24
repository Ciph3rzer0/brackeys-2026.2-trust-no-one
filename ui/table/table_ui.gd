class_name TableUI
extends PanelContainer

var _database: Database

func _ready() -> void:
	_database = Database.new()
	
	assert(_database != null)
	set_table_items(_database)

func set_table_items(database: Database):
	_database = database
	
	for i in range(database.rows.size()):
		var new_source_row: DatabaseRow = database.rows[i]
		var new_table_row: TableRow = %TableRow.duplicate()
		new_table_row.set_source_row(new_source_row)
		new_table_row.visible = true
		%TableBody.add_child(new_table_row)
	
