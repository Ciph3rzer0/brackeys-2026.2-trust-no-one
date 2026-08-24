class_name TextEditFilter
extends TextEdit

## Helper class which emits a signal with 'text' whenever it's updated.

signal filter_changed(text: String)

func _ready() -> void:
	text_changed.connect(_on_text_changed)
	text_set.connect(_on_text_changed)

func _on_text_changed() -> void:
	filter_changed.emit(text)
