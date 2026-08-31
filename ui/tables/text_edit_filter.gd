class_name SingleLineTextFilter
extends LineEdit

## Helper class which emits a signal with 'text' whenever it's updated.

signal filter_changed(text: String)

func _ready() -> void:
	text_changed.connect(_on_text_changed)

func _on_text_changed(new_text: String) -> void:
	filter_changed.emit(new_text)
