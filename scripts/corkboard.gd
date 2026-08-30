class_name Corkboard
extends ReportHolder3D

@export var report_scene: PackedScene = preload("res://scenes/crime_report_3d.tscn")
@export var initial_report_quests: Array[Quest] = [
	preload("res://scripts/quests/haircut-robbery.tres"), 
	preload("res://scripts/quests/late-nighter.tres"),
	preload("res://scripts/quests/streaker.tres"),
	preload("res://scripts/quests/airport-camper.tres"),
	preload("res://scripts/quests/speed-racer.tres"),
	preload("res://scripts/quests/stalker.tres"),
	preload("res://scripts/quests/hospital-egging.tres"),
	preload("res://scripts/quests/park-drive.tres"),
	preload("res://scripts/quests/painted-lady.tres"),
	preload("res://scripts/quests/plate-swapper.tres"),
	preload("res://scripts/quests/a-case-of-gas.tres"),
	preload("res://scripts/quests/another-speedster.tres")	
	]

func _ready() -> void:
	for initial_quest in initial_report_quests:
		spawn_report(initial_quest)

func spawn_report(quest_override: Quest = null, scene_override: PackedScene = null) -> CrimeReport3D:
	var scene_to_spawn := scene_override if scene_override else report_scene
	if !scene_to_spawn:
		push_warning("Cannot pin a crime report: no report scene is configured.")
		return null

	var report := scene_to_spawn.instantiate() as CrimeReport3D
	if !report:
		push_warning("The configured report scene must have a CrimeReport3D root.")
		return null

	if quest_override:
		report.quest = quest_override
	add_child(report)

	if !place_report(report):
		report.queue_free()
		return null

	QuestSystem.register_report(report)
	return report
