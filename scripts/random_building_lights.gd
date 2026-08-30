extends Node3D

signal light_toggled(light: Light3D, is_on: bool)

@export_range(0.1, 300.0, 0.1) var minimum_interval_seconds := 20.0
@export_range(0.1, 300.0, 0.1) var maximum_interval_seconds := 30.0

var _lights: Array[Light3D] = []
var _timer: Timer
var _random := RandomNumberGenerator.new()


func _ready() -> void:
	for child in get_children():
		var light := child as Light3D
		if light:
			_lights.append(light)

	if _lights.is_empty():
		push_warning("%s has no direct child lights to randomize." % name)
		return

	_random.randomize()
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_toggle_random_light)
	add_child(_timer)
	_schedule_next_toggle()


func _toggle_random_light() -> void:
	var light := _lights[_random.randi_range(0, _lights.size() - 1)]
	light.visible = !light.visible
	light_toggled.emit(light, light.visible)
	_schedule_next_toggle()


func _schedule_next_toggle() -> void:
	var minimum := maxf(0.1, minimum_interval_seconds)
	var maximum := maxf(minimum, maximum_interval_seconds)
	_timer.start(_random.randf_range(minimum, maximum))
