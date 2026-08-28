class_name Corkboard
extends ReportHolder3D

@export var report_scene: PackedScene = preload("res://scenes/crime_report_3d.tscn")
@export var initial_report_quests: Array[Quest] = [preload("res://scripts/quests/first_quest.tres"), preload("res://scripts/quests/2_quest.tres")]

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

	return report
