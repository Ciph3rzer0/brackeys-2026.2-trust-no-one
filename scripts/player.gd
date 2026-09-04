#https://github.com/Linko-3D/Godot-Simple-First-Person-Controller/blob/main/player/player.gd
class_name Player
extends CharacterBody3D

@export var footstep_sound : Array[AudioStream]

@export var cam : Camera3D
@export var viewports: Array[SubViewport]

@onready var interaction_ray: RayCast3D = $Camera3D/InteractionRay
@onready var interaction_prompt: Label = $InteractionUI/InteractionPrompt
@onready var crosshair_dot: Control = $InteractionUI/CrosshairDot
@onready var held_report_anchor: Node3D = $Camera3D/HeldReportAnchor

var run_speed = 4.5
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
var _active_input_viewport: SubViewport

func _enter_tree() -> void:
	GameManager.set_player(self)


func _exit_tree() -> void:
	GameManager.clear_player(self)


func _ready() -> void:
	set_mouse_free(false)

func set_mouse_free(val: bool):
	is_mouse_free = val
	crosshair_dot.visible = !val
	if val:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if false && event.is_action_pressed("ui_cancel"):
		set_mouse_free(!is_mouse_free)
		if _mounted_object and !is_mouse_free:
			_release_input_viewport_focus()
		get_viewport().set_input_as_handled()
		return
	
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
	if is_instance_valid(_active_input_viewport):
		if _active_input_viewport.gui_get_focus_owner():
			return _active_input_viewport
	else:
		_active_input_viewport = null

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


func _has_focused_text_input() -> bool:
	var focused_viewport := find_focused_viewport()
	if !focused_viewport:
		return false
	var focused_control := focused_viewport.gui_get_focus_owner()
	return focused_control is LineEdit or focused_control is TextEdit


func register_input_viewport(viewport: SubViewport) -> void:
	if is_instance_valid(viewport) and !viewports.has(viewport):
		viewports.append(viewport)


func set_active_input_viewport(viewport: SubViewport) -> void:
	if !is_instance_valid(viewport):
		return
	register_input_viewport(viewport)
	_active_input_viewport = viewport

	# SubViewports keep focus independently. Release stale focus so a control
	# on an older screen cannot steal keys from the screen just clicked.
	for other_viewport in viewports:
		if is_instance_valid(other_viewport) and other_viewport != viewport:
			other_viewport.gui_release_focus()


func unregister_input_viewport(viewport: SubViewport) -> void:
	viewports.erase(viewport)
	if _active_input_viewport == viewport:
		_active_input_viewport = null

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
	%LookAtMapButton.visible = true
	%GetUpButton.visible = true
	%LookAtComputerButton.visible = false
	mount.play_mount_sound()
	mount.notify_mounted()


func get_available_mount() -> InteractableMount:
	var mounts := get_tree().get_nodes_in_group("InteractiveMount")
	for node in mounts:
		var mount := node as InteractableMount
		if mount and mount.overlaps_body(self):
			return mount
	return null

func dismount():
	var previous_mount := _mounted_object
	_mounted_object = null
	_release_input_viewport_focus()
	change_fov(65.0, 0.05)
	set_mouse_free(false)
	%GetUpButton.visible = false
	%LookAtMapButton.visible = false
	%LookAtComputerButton.visible = false
	if previous_mount:
		previous_mount.notify_dismounted()


func _release_input_viewport_focus() -> void:
	for viewport in viewports:
		if is_instance_valid(viewport):
			viewport.gui_release_focus()
	_active_input_viewport = null


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
	var mouse_mode := Input.get_mouse_mode()
	crosshair_dot.visible = (
		mouse_mode == Input.MOUSE_MODE_HIDDEN
		or mouse_mode == Input.MOUSE_MODE_CAPTURED
		or mouse_mode == Input.MOUSE_MODE_CONFINED_HIDDEN
	)

	var interactable := get_faced_interactable()
	var available_mount := get_available_mount() if !_mounted_object else null
	var prompt_target: Node = interactable if interactable else available_mount
	
	interaction_prompt.visible = !is_mouse_free and prompt_target != null
	if interaction_prompt.visible and !_mounted_object:
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


func get_fax_rejection_reason() -> String:
	if !held_report:
		return "no report is ready to fax"

	var submitted_plate := held_report.get_plate_entry().strip_edges().to_upper()
	if submitted_plate.is_empty():
		return "enter a license plate on the report before faxing"
	if GameManager.database == null:
		return "the vehicle database is unavailable"
	if !GameManager.database.has_vehicle_plate(submitted_plate):
		return "license plate not found in the database"

	return ""


func pick_up_report(report: CrimeReport3D) -> bool:
	if held_report or !report:
		return false

	if report.current_holder:
		report.current_holder.remove_report(report)

	held_report = report
	report.reparent(held_report_anchor, false)
	report.global_transform = held_report_anchor.global_transform.orthonormalized()
	report.set_held(true)
	# Turn off Report collision while it's in your hand
	interaction_ray.set_collision_mask_value(3, false)
	# Turn on Report Slot collision
	interaction_ray.set_collision_mask_value(7, true)
	return true

func place_held_report(holder: ReportHolder3D) -> bool:
	if !held_report or !holder:
		return false

	var report := held_report
	if !holder.place_report(report):
		return false
	
	_release_held_report()
	return true


func _release_held_report():
	held_report = null
	
	# Turn on Report collision
	interaction_ray.set_collision_mask_value(3, true)
	# Turn off Report Slot collision
	interaction_ray.set_collision_mask_value(7, false)

func fax_held_report() -> bool:
	if !held_report:
		return false
	
	var rejection_reason := get_fax_rejection_reason()
	if !rejection_reason.is_empty():
		print("fax rejected: ", rejection_reason)
		return false
	
	var report := held_report
	var quest := report.quest
	var submitted_plate := report.get_plate_entry().strip_edges().to_upper()
	held_report = null
	print("report faxed: ", report.get_report_title())
	QuestSystem.submit_faxed_report(report, quest, submitted_plate)
	print("report ", report)
	
	_release_held_report()
	report.queue_free()
	
	return true

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector( "pc_right", "pc_left", "pc_back" ,"pc_forward")
	
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

		speed = walk_speed
		# Crouch with Control
		if Input.is_key_pressed(KEY_CTRL):
			speed = crouch_speed
		# Walk with Shift
		elif Input.is_key_pressed(KEY_SHIFT):
			speed = run_speed

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


func play_random_footstep_sound() -> void:
	if footstep_sound.size() > 0:
		$FootstepSound.stream = footstep_sound.pick_random()
		$FootstepSound.play()


func _on_get_up_button_pressed() -> void:
	dismount()


func _on_look_at_map_button_pressed() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	var look_dir = Vector3(deg_to_rad(-5), deg_to_rad(70), deg_to_rad(-0))
	tween.tween_property(self, "rotation", look_dir, 0.5)

	#rotation.y = (deg_to_rad(70))
	#rotation.x = (deg_to_rad(-5))
	%LookAtMapButton.visible = false
	%LookAtComputerButton.visible = true


func _on_look_at_computer_button_pressed() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "rotation", Vector3.ZERO, 0.5)
	%LookAtMapButton.visible = true
	%LookAtComputerButton.visible = false
