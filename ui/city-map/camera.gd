extends Area2D

@export var camera_name: String

func _ready() -> void:
	assert(camera_name)


func _on_body_entered(vehicle: Node2D) -> void:
	log_car_sighting(vehicle)
	$ALERT.visible = true


func _on_body_exited(_body: Node2D) -> void:
	$ALERT.visible = false


func log_car_sighting(vehicle: Node2D):
	print("Camera ", camera_name, " sees ", vehicle.name)
	var sighting = SchemaVehicleSightings.new()
	#sighting.sighting_id: int
	sighting.unix_timestamp = Time.get_unix_time_from_system()
	sighting.camera_id = camera_name
	#sighting.vehicle_plate: String
	#sighting.vehicle_color: String
	#sighting.vehicle_type: String
	#sighting.vehicle_features: Array[String]

	
