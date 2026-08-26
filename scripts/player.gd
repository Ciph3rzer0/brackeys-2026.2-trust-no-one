#https://github.com/Linko-3D/Godot-Simple-First-Person-Controller/blob/main/player/player.gd
extends CharacterBody3D

@export var footstep_sound : Array[AudioStream]

@export var cam : Camera3D

var run_speed = 5.5
var speed = run_speed
var walk_speed = 3
var crouch_speed = 1.8

var jump_velocity = 7
var landing_velocity

var distance = 0
var footstep_distance = 2.1

var is_mouse_free := false
var _mounted_object: InteractableMount

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func set_mouse_free(val: bool):
	is_mouse_free = val
	if val:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		set_mouse_free(!is_mouse_free)
		get_viewport().set_input_as_handled()
	
	if is_mouse_free: return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x / 10
		cam.rotation_degrees.x -= event.relative.y / 10
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)

func _unhandled_input(event: InputEvent) -> void:
	if (!_mounted_object or !is_mouse_free) and event.is_action_pressed("pc_interact"):
		if _mounted_object:
			dismount()
		else:
			try_mount()
	
	if _mounted_object:
		if event is InputEventKey:
			_mounted_object.push_keypress_to_viewport(event)

func try_mount():
	var mounts = get_tree().get_nodes_in_group("InteractiveMount") as Array[InteractableMount]
	for mount in mounts:
		if mount.overlaps_body(self):
			global_position = mount.global_position
			global_rotation = mount.global_rotation
			_mounted_object = mount
			cam.rotation_degrees.x = 0
			set_mouse_free(true)

func dismount():
	_mounted_object = null
	set_mouse_free(false)

var exit_button_held_timer := 0.0
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_exit_game"):
		exit_button_held_timer += delta
		if (exit_button_held_timer) > 0.5:
			get_tree().quit()
	else:
		exit_button_held_timer = 0
		
func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector( "pc_right", "pc_left", "pc_back" ,"pc_forward")
	
	# If the player moves while camera is locked (look mode), dismount
	if !is_mouse_free and !input_dir.is_zero_approx():
		dismount()
	
	# No player movement while mounted
	if _mounted_object: return
	
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
		landing_velocity = -velocity.y
		distance = 0

	# Jump with Space - only if on floor and no ceiling above
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = jump_velocity
		play_random_footstep_sound()

	$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 1.85, 0.1)

	if is_on_floor():
		if landing_velocity != 0:
			landing_animation(landing_velocity)
			landing_velocity = 0

		speed = run_speed
		# Crouch with Control
		if Input.is_key_pressed(KEY_CTRL):
			speed = crouch_speed
		# Walk with Shift
		elif Input.is_key_pressed(KEY_SHIFT):
			speed = walk_speed

	if Input.is_key_pressed(KEY_CTRL):
		$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 1.38, 0.1)

	$CapsuleBody.mesh.height = $CollisionShape3D.shape.height
	#%HeadPosition.position.y = $CollisionShape3D.shape.height - 0.25

	# Movement inputs
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	distance += get_real_velocity().length() * delta

	if distance >= footstep_distance:
		distance = 0
		if speed > walk_speed:
			play_random_footstep_sound()

	move_and_slide()


func landing_animation(landing_velocity):
	if landing_velocity >= 2:
		play_random_footstep_sound()

	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	var amplitude = clamp(landing_velocity / 100, 0.0, 0.3)
#
	#tween.tween_property(%LandingAnimation, "position:y", -amplitude, amplitude)
	#tween.tween_property(%LandingAnimation, "position:y", 0, amplitude)


func play_random_footstep_sound() -> void:
	if footstep_sound.size() > 0:
		$FootstepSound.stream = footstep_sound.pick_random()
		$FootstepSound.play()
