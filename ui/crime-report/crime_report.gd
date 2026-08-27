extends Control

@export var quest: Quest: set = set_quest

func _ready() -> void:
	set_quest(quest)
	QuestSystem.new_quest_assigned.connect(_on_new_quest_assigned)

func _on_new_quest_assigned(quest: Quest):
	set_quest(quest)

func set_quest(_quest: Quest):
	if !_quest: return
	quest = _quest
	
	if is_node_ready():
		%Time.text = Time.get_datetime_string_from_unix_time(quest.datetime_start_unix)
		%Incident.text = quest.incident
		%Plate.text = quest.details

func _on_submit_button_pressed() -> void:
	var plate = %PlateEntryTextEdit.text
	QuestSystem.submit_plate_to_quest(quest, plate)
	print("Submitted ", plate)
