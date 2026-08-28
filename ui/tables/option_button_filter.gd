class_name OptionButtonFilter
extends OptionButton

## Helper class which emits a signal with 'text' whenever it's updated.

signal filter_changed(text: String)

func _ready() -> void:
	item_selected.connect(_on_item_selected)

func _on_item_selected(i: int) -> void:
	print(i, " ", selected)
	print(get_item_text(i), " ", get_item_text(selected))
	filter_changed.emit(get_item_text(i))
