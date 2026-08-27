class_name QuestButton
extends Button

@export var quest: Quest

func _pressed() -> void:
	print("START QUEST ", quest)
