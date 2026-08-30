#https://github.com/Linko-3D/Godot-Simple-First-Person-Controller/blob/main/player/player.gd
class_name Player
extends CharacterBody3D

@export var footstep_sound : Array[AudioStream]

@export var cam : Camera3D
@export var viewports: Array[SubViewport]

@onready var interaction_ray: RayCast3D = $Camera3D/InteractionRay
@onready var interaction_prompt: Label = $InteractionUI/InteractionPrompt
@onready var held_report_anchor: Node3D = $Camera3D/HeldReportAnchor

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
var held_report: CrimeReport3D

func _enter_tree() -> void:
	GameManager.set_player(self)

func _ready() -> void:
	set_mouse_free(false)

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
	if event.is_action_pressed("pc_interact") and !_mounted_object and !is_mouse_free:
		var interactable := get_faced_interactable()
		if interactable:
			interactable.interact(self)
			get_viewport().set_input_as_handled()
			return

	if (!_mounted_object or !is_mouse_free) and event.is_action_pressed("pc_interact"):
		if _mounted_object:
			dismount()
		else:
			try_mount()
	
	# if _mounted_object:
	# 	if event is InputEventKey or event is InputEventPanGesture:
	# 		if _mounted_object.push_event_to_viewport(event):
	# 			get_viewport().set_input_as_handled()

	if !is_mouse_free: return

	var viewport = find_focused_viewport()
	if viewport:
		if event is InputEventKey or event is InputEventPanGesture:
			viewport.push_input(event, true)
			get_viewport().set_input_as_handled()

func find_focused_viewport() -> SubViewport:
	var index := 0
	while index < viewports.size():
		var vp := viewports[index]
		if !is_instance_valid(vp):
			viewports.remove_at(index)
			continue
		if vp.gui_get_focus_owner():
			return vp
		index += 1
	return null


func register_input_viewport(viewport: SubViewport) -> void:
	if is_instance_valid(viewport) and !viewports.has(viewport):
		viewports.append(viewport)


func unregister_input_viewport(viewport: SubViewport) -> void:
	viewports.erase(viewport)

func try_mount():
	var mount := get_available_mount()
	if !mount:
		return

	global_position = mount.global_position
	global_rotation = mount.global_rotation
	_mounted_object = mount
	cam.rotation_degrees.x = 0
	change_fov(50.0, 0.27)
	set_mouse_free(true)


func get_available_mount() -> InteractableMount:
	var mounts := get_tree().get_nodes_in_group("InteractiveMount")
	for node in mounts:
		var mount := node as InteractableMount
		if mount and mount.overlaps_body(self):
			return mount
	return null

func dismount():
	_mounted_object = null
	change_fov(75.0, 0.05)
	set_mouse_free(false)


var fov_tween: Tween
func change_fov(target_fov: float, duration: float) -> void:
	# Kill any active tween to prevent jittery, conflicting animations
	if fov_tween and fov_tween.is_valid():
		fov_tween.kill()
	
	# Create a new tween and animate the fov property
	fov_tween = create_tween()
	fov_tween.tween_property(cam, "fov", target_fov, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

var exit_button_held_timer := 0.0
func _process(delta: float) -> void:
	var interactable := get_faced_interactable()
	var available_mount := get_available_mount() if !_mounted_object else null
	var prompt_target: Node = interactable if interactable else available_mount
	interaction_prompt.visible = !_mounted_object and !is_mouse_free and prompt_target != null
	if interaction_prompt.visible:
		if prompt_target.has_method("get_interaction_text"):
			interaction_prompt.text = prompt_target.get_interaction_text(self)
		else:
			interaction_prompt.text = "press e to interact"

	if Input.is_action_pressed("ui_exit_game"):
		exit_button_held_timer += delta
		if (exit_button_held_timer) > 0.5:
			get_tree().quit()
	else:
		exit_button_held_timer = 0

func get_faced_interactable() -> Node:
	if !interaction_ray.is_colliding():
		return null

	var node := interaction_ray.get_collider() as Node
	while node:
		if node.is_in_group("Interactable") and node.has_method("interact"):
			if !node.has_method("can_interact") or node.can_interact(self):
				return node
		node = node.get_parent()

	return null

func has_held_report() -> bool:
	return held_report != null

func pick_up_report(report: CrimeReport3D) -> bool:
	if held_report or !report:
		return false

	if report.current_holder:
		report.current_holder.remove_report(report)

	held_report = report
	report.reparent(held_report_anchor, false)
	report.global_transform = held_report_anchor.global_transform.orthonormalized()
	report.set_held(true)
	return true

func place_held_report(holder: ReportHolder3D) -> bool:
	if !held_report or !holder:
		return false

	var report := held_report
	if !holder.place_report(report):
		return false

	held_report = null
	return true

func fax_held_report() -> bool:
	if !held_report:
		return false

	var report := held_report
	var quest := report.quest
	var submitted_plate := report.get_plate_entry()
	held_report = null
	print("report faxed: ", report.get_report_title())
	QuestSystem.submit_plate_to_quest(quest, submitted_plate)
	print("report ", report)
	report.queue_free()

	return true
		
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
