extends Control

@export var quest: Quest: set = set_quest

func _ready() -> void:
	%Time.text = Time.get_datetime_string_from_unix_time(quest.datetime_start_unix)
	%Incident.text = quest.incident
	%Plate.text = quest.details

func set_quest(_quest: Quest):
	if !_quest: return
	quest = _quest
