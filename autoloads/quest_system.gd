extends Node

var _active_quest: Quest

signal new_quest_assigned(quest: Quest)
signal plate_submitted_for_quest(quest: Quest, plate: String)

func assign_new_quest(quest: Quest = null):
	# if _active_quest:
	# 	print("Quest already active")
	# 	return
	
	if !quest:
		print("Generating new quest")
		quest = Quest.new()
		quest.incident = ""
		quest.datetime_start = "2026-07-08T13:00:00"
		quest.datetime_end = "2026-07-08T16:00:00"
		quest.details = "The suspect vehicle's plate was reported as XK3-JT_1."
		quest.correct_plate = "XK3-JT01"
	
	_active_quest = quest
	new_quest_assigned.emit(quest)

func submit_plate_to_quest(quest: Quest, plate: String):
	#assert(quest == _active_quest)
	
	if compare_alphanumeric_only(plate, quest.correct_plate):
		print("CORRECT !!!!")
	else:
		print("wrong")
	plate_submitted_for_quest.emit(quest, plate)

func compare_alphanumeric_only(str1: String, str2: String) -> bool:
	var clean1 = get_alphanumeric_only(str1)
	var clean2 = get_alphanumeric_only(str2)
	return clean1 == clean2

func get_alphanumeric_only(input: String) -> String:
	var regex = RegEx.new()
	regex.compile(r"[^a-zA-Z0-9]")
	# Remove everything that is NOT a letter or number, then convert to lowercase
	var stripped = regex.sub(input, "", true)
	return stripped.to_lower()
