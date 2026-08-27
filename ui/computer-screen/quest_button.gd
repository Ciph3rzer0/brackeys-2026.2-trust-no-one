class_name QuestButton
extends Button

@export var quest: Quest

func _pressed() -> void:
	QuestSystem.assign_new_quest(quest)
	print("START QUEST ", quest)
