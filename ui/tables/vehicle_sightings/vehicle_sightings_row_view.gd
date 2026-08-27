class_name VehicleSightingsRowView
extends HBoxContainer

var source_row: SchemaVehicleSightings

func set_source_row(_source_row: SchemaVehicleSightings) -> void:
	source_row = _source_row
	update()

func update() -> void:
	$SightingID.text = str(source_row.sighting_id)
	$LicensePlate.text = source_row.vehicle_plate
	#$Timestamp.text = DateHelper.month_day_time(source_row.unix_timestamp)
	$Date.text = DateHelper.month_day(source_row.unix_timestamp)
	$Time.text = DateHelper.time_12h(source_row.unix_timestamp)
	$CameraID.text = source_row.camera_id
	$VehicleColor.text = source_row.vehicle_color
	$VehicleType.text = source_row.vehicle_type
	$Features.text = ", ".join(PackedStringArray(source_row.vehicle_features))
