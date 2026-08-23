class_name Database

var rows: Array[DatabaseRow]

func _ready():
	seed(7)
	rows = MockDataFactory.generate_rows(100)

	