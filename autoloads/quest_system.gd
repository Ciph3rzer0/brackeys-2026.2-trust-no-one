extends Node

var _active_quest: Quest

signal new_quest_assigned(quest: Quest)

func assign_new_quest():
	if _active_quest:
		print("Quest already active")
		return
	
	print("Generating new quest")
	var quest = Quest.new()
	quest.incident = ""
	quest.datetime_start = Time.get_unix_time_from_datetime_string("2026-07-08T13:00:00")
	quest.datetime_end = Time.get_unix_time_from_datetime_string("2026-07-08T16:00:00")
	quest.plate = "XK3-JT_1"
	quest.correct_plate = "XK3-JT01"
	
	_active_quest = quest
	new_quest_assigned.emit(quest)
