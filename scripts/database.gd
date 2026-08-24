class_name Database

var rows: Array[DatabaseRow]

func _init():
	seed(7)
	rows = MockDataFactory.generate_rows(100)
