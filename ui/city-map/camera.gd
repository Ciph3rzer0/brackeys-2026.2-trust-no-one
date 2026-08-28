extends Area2D

@export var city_map: CityMap
@export var camera_name: String

func _ready() -> void:
	assert(camera_name)
	assert(city_map)


func _on_body_entered(vehicle: Node2D) -> void:
	log_car_sighting(vehicle)
	$ALERT.visible = true


func _on_body_exited(_body: Node2D) -> void:
	$ALERT.visible = false


func log_car_sighting(vehicle: Vehicle):
	print("Camera ", camera_name, " sees ", vehicle.name)
	var sighting = SchemaVehicleSightings.new()
	#sighting.sighting_id: int
	sighting.unix_timestamp = city_map.current_time
	sighting.camera_id = camera_name
	sighting.vehicle_plate = vehicle.plate
	sighting.vehicle_color = vehicle.color
	sighting.vehicle_type = vehicle.type
	sighting.vehicle_features = vehicle.features
	GameManager.database.vehicle_sightings.append(sighting)
	GameManager.database.refresh()
	CSVHelper.append_to_csv(sighting)
