class_name LineEditFilter
extends LineEdit

enum ValidationMode {
	DAY,
	TIME,
}

signal filter_changed(text: String)

@export var validation_mode := ValidationMode.TIME
@export var validation_hint := ""

var _external_validation_error := ""


func _ready() -> void:
	text_changed.connect(_on_text_changed)
	_update_validation_display()


func set_external_validation_error(message: String) -> void:
	_external_validation_error = message
	_update_validation_display()


func _on_text_changed(new_text: String) -> void:
	_update_validation_display()
	filter_changed.emit(new_text)


func _update_validation_display() -> void:
	var error_message := _get_local_validation_error()
	if error_message.is_empty():
		error_message = _external_validation_error

	if error_message.is_empty():
		remove_theme_color_override("font_color")
		remove_theme_stylebox_override("normal")
		remove_theme_stylebox_override("focus")
		tooltip_text = validation_hint
		return

	add_theme_color_override("font_color", Color(0.7, 0.04, 0.04))
	var source_style := get_theme_stylebox("normal")
	if source_style is StyleBoxFlat:
		var invalid_style := source_style.duplicate() as StyleBoxFlat
		invalid_style.border_color = Color(0.85, 0.12, 0.08)
		invalid_style.border_width_left = maxi(2, invalid_style.border_width_left)
		invalid_style.border_width_top = maxi(2, invalid_style.border_width_top)
		invalid_style.border_width_right = maxi(2, invalid_style.border_width_right)
		invalid_style.border_width_bottom = maxi(2, invalid_style.border_width_bottom)
		add_theme_stylebox_override("normal", invalid_style)
		add_theme_stylebox_override("focus", invalid_style)
	tooltip_text = error_message


func _get_local_validation_error() -> String:
	var value := text.strip_edges()
	if value.is_empty():
		return ""

	match validation_mode:
		ValidationMode.DAY:
			if !is_valid_day_text(value):
				return "Enter a day from 1 to 31."
		ValidationMode.TIME:
			if !is_valid_time_text(value):
				return "Enter a 24-hour time in H:MM or HH:MM format."
	return ""


static func is_valid_day_text(value: String) -> bool:
	var normalized := value.strip_edges()
	return (
		!normalized.is_empty()
		and normalized.length() <= 2
		and normalized.is_valid_int()
		and normalized.to_int() >= 1
		and normalized.to_int() <= 31
	)


static func is_valid_time_text(value: String) -> bool:
	var normalized := normalize_time_text(value)
	if normalized.length() != 5 or normalized.substr(2, 1) != ":":
		return false

	var hour_text := normalized.substr(0, 2)
	var minute_text := normalized.substr(3, 2)
	return (
		hour_text.is_valid_int()
		and minute_text.is_valid_int()
		and hour_text.to_int() >= 0
		and hour_text.to_int() <= 23
		and minute_text.to_int() >= 0
		and minute_text.to_int() <= 59
	)


static func normalize_time_text(value: String) -> String:
	var normalized := value.strip_edges()
	if normalized.length() == 4 and normalized.substr(1, 1) == ":":
		return "0" + normalized
	return normalized
