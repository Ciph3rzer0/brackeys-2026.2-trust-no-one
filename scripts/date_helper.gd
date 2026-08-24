class_name DateHelper

const MONTH_ABBR: Array[String] = [
	"", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
]

const WEEKDAY_ABBR: Array[String] = [
	"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
]

## "Apr 2"
static func month_day(unix_time: int) -> String:
	var dt := Time.get_datetime_dict_from_unix_time(unix_time)
	return "%s %d" % [MONTH_ABBR[dt.month], dt.day]

## "Apr 2" if current year, "Apr 2, 2025" otherwise
static func month_day_smart(unix_time: int) -> String:
	var dt := Time.get_datetime_dict_from_unix_time(unix_time)
	var now := Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_system() as int)
	if dt.year != now.year:
		return "%s %d, %d" % [MONTH_ABBR[dt.month], dt.day, dt.year]
	return "%s %d" % [MONTH_ABBR[dt.month], dt.day]

## "9:23 AM"
static func time_12h(unix_time: int) -> String:
	var dt := Time.get_datetime_dict_from_unix_time(unix_time)
	var period := "am" if dt.hour < 12 else "pm"
	var hour_12: int = dt.hour % 12
	if hour_12 == 0:
		hour_12 = 12
	return "%d:%02d %s" % [hour_12, dt.minute, period]

## "Apr 2, 9:23 AM"
static func month_day_time(unix_time: int) -> String:
	return "%s, %s" % [month_day(unix_time), time_12h(unix_time)]

## "Thu"
static func weekday_abbr(unix_time: int) -> String:
	var dt := Time.get_datetime_dict_from_unix_time(unix_time)
	return WEEKDAY_ABBR[dt.weekday]

## "3 hours ago", "just now", "5 days ago"
static func relative(unix_time: int) -> String:
	var now := Time.get_unix_time_from_system()
	var delta := int(now) - unix_time

	if delta < 60:
		return "just now"
	elif delta < 3600:
		@warning_ignore("integer_division")
		var mins := delta / 60
		return "%d min%s ago" % [mins, "" if mins == 1 else "s"]
	elif delta < 86400:
		@warning_ignore("integer_division")
		var hours := delta / 3600
		return "%d hour%s ago" % [hours, "" if hours == 1 else "s"]
	elif delta < 604800:
		@warning_ignore("integer_division")
		var days := delta / 86400
		return "%d day%s ago" % [days, "" if days == 1 else "s"]
	else:
		return month_day_smart(unix_time)
