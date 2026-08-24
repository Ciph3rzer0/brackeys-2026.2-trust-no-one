class_name VehicleSightingsRowView
extends HBoxContainer

var source_row: SchemaVehicleSightings

func set_source_row(_source_row: SchemaVehicleSightings) -> void:
	source_row = _source_row
	update()

func update() -> void:
	$SightingID.text = str(source_row.sighting_id)
	$LicensePlate.text = source_row.car_plate
	$Timestamp.text = source_row.timestamp
	$CameraID.text = source_row.camera_id
	$VehicleColor.text = source_row.vehicle_color
	$VehicleType.text = source_row.vehicle_type
	$Features.text = ", ".join(PackedStringArray(source_row.vehicle_features))
