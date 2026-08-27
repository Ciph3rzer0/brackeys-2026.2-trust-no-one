class_name Quest
extends Resource

@export var correct_plate: String

@export var incident: String
@export_multiline var details: String


## Actual stored value — a Unix timestamp (int). Hidden from the inspector,
## but still saved with the resource. Use this from code: my_resource.date_unix
@export_storage var datetime_start_unix: int = 0
 
## What shows in the inspector: type a date like "2026-08-26".
@export var datetime_start: String = "":
	get:
		if datetime_start_unix == 0:
			return ""
		return Time.get_date_string_from_unix_time(datetime_start_unix)
	set(value):
		if value.is_empty():
			datetime_start_unix = 0
			return
		var parsed := Time.get_unix_time_from_datetime_string(value)
		if parsed == 0 and value != "1970-01-01":
			push_warning("DatedResource: couldn't parse date '%s', expected YYYY-MM-DD" % value)
		datetime_start_unix = parsed

## Actual stored value — a Unix timestamp (int). Hidden from the inspector,
## but still saved with the resource. Use this from code: my_resource.date_unix
@export_storage var datetime_end_unix: int = 0
 
## What shows in the inspector: type a date like "2026-08-26".
@export var datetime_end: String = "":
	get:
		if datetime_end_unix == 0:
			return ""
		return Time.get_date_string_from_unix_time(datetime_end_unix)
	set(value):
		if value.is_empty():
			datetime_end_unix = 0
			return
		var parsed := Time.get_unix_time_from_datetime_string(value)
		if parsed == 0 and value != "1970-01-01":
			push_warning("DatedResource: couldn't parse date '%s', expected YYYY-MM-DD" % value)
		datetime_end_unix = parsed
