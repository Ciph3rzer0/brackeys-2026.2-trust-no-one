class_name Corkboard
extends ReportHolder3D

@export var report_scene: PackedScene = preload("res://scenes/crime_report_3d.tscn")
@export_range(0.0, 600.0, 1.0, "or_greater") var refill_delay_seconds := 60.0
@export var initial_report_quests: Array[Quest] = [
	preload("res://scripts/quests/late-nighter.tres"),
	preload("res://scripts/quests/haircut-robbery.tres"), 
	preload("res://scripts/quests/streaker.tres"),
	preload("res://scripts/quests/airport-camper.tres"),
	preload("res://scripts/quests/speed-racer.tres"),
	preload("res://scripts/quests/stalker.tres"),
	# preload("res://scripts/quests/hospital-egging.tres"),
	preload("res://scripts/quests/painted-lady.tres"),
	preload("res://scripts/quests/plate-swapper.tres"),
	#preload("res://scripts/quests/a-case-of-gas.tres"),
	preload("res://scripts/quests/another-speedster.tres"),
	preload("res://scripts/quests/park-drive.tres")
	]

var _queued_reports: Array[Dictionary] = []
var _slot_refill_generations := {}
var _next_report_number := 1


func _ready() -> void:
	report_placed.connect(_on_report_placed)
	report_removed.connect(_on_report_removed)
	for initial_quest in initial_report_quests:
		spawn_report(initial_quest)


func spawn_report(quest_override: Quest = null, scene_override: PackedScene = null) -> CrimeReport3D:
	var scene_to_spawn := scene_override if scene_override else report_scene
	if !scene_to_spawn:
		push_warning("Cannot pin a crime report: no report scene is configured.")
		return null
	var report_number := _next_report_number
	_next_report_number += 1

	var open_slot := get_first_open_slot()
	if !open_slot:
		_queue_report(quest_override, scene_to_spawn, report_number)
		return null

	return _spawn_report_in_slot(
		quest_override,
		scene_to_spawn,
		open_slot,
		true,
		report_number
	)


func get_queued_report_count() -> int:
	return _queued_reports.size()


func _queue_report(quest: Quest, scene: PackedScene, report_number: int) -> void:
	_queued_reports.append({
		"quest": quest,
		"scene": scene,
		"report_number": report_number,
	})
	QuestSystem.reserve_cases(1)


func _spawn_report_in_slot(
	quest_override: Quest,
	scene_to_spawn: PackedScene,
	slot: Node3D,
	count_as_new_case: bool,
	report_number: int
) -> CrimeReport3D:
	var report := scene_to_spawn.instantiate() as CrimeReport3D
	if !report:
		push_warning("The configured report scene must have a CrimeReport3D root.")
		return null

	if quest_override:
		report.quest = quest_override
	report.report_number = report_number
	add_child(report)

	if !place_report_in_slot(report, slot):
		report.queue_free()
		return null

	QuestSystem.register_report(report, count_as_new_case)
	return report


func _on_report_placed(_report: CrimeReport3D, slot: Node3D) -> void:
	var slot_id := slot.get_instance_id()
	_slot_refill_generations[slot_id] = int(_slot_refill_generations.get(slot_id, 0)) + 1


func _on_report_removed(report: CrimeReport3D) -> void:
	if _queued_reports.is_empty():
		return

	var emptied_slot := report.get_parent() as Node3D
	var slot_container := get_node_or_null(slot_container_path)
	if !emptied_slot or emptied_slot.get_parent() != slot_container:
		return

	var slot_id := emptied_slot.get_instance_id()
	var generation := int(_slot_refill_generations.get(slot_id, 0)) + 1
	_slot_refill_generations[slot_id] = generation
	_refill_slot_after_delay(emptied_slot, generation)


func _refill_slot_after_delay(slot: Node3D, generation: int) -> void:
	await get_tree().create_timer(refill_delay_seconds, false).timeout
	if !is_instance_valid(slot) or _queued_reports.is_empty():
		return

	var slot_id := slot.get_instance_id()
	if int(_slot_refill_generations.get(slot_id, 0)) != generation:
		return
	if get_report_in_slot(slot) != null:
		return

	var queued_report: Dictionary = _queued_reports.pop_front()
	var spawned_report := _spawn_report_in_slot(
		queued_report.get("quest") as Quest,
		queued_report.get("scene") as PackedScene,
		slot,
		false,
		int(queued_report.get("report_number", 0))
	)
	if !spawned_report:
		_queued_reports.push_front(queued_report)
