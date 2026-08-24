extends HBoxContainer
class_name RmsPersonsRowView

var source_row: SchemaRmsPersons

func set_source_row(_source_row: SchemaRmsPersons) -> void:
	source_row = _source_row
	update()

func update() -> void:
	$FirstName.text = source_row.first_name
	$LastName.text = source_row.last_name
	$Plate.text = source_row.car_plate
	$Home.text = source_row.home_address
