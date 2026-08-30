extends Node

var _active_quest: Quest
var resolved_cases := 0
var lawsuit_cases := 0

signal new_quest_assigned(quest: Quest)
signal plate_submitted_for_quest(quest: Quest, plate: String)
signal case_statistics_changed(resolved_cases: int, lawsuit_cases: int)

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

func submit_plate_to_quest(quest: Quest, plate: String) -> bool:
	#assert(quest == _active_quest)

	var is_correct := plate.strip_edges().to_upper() == quest.correct_plate.strip_edges().to_upper()
	if is_correct:
		print("CORRECT !!!!")
	else:
		print("wrong")
	plate_submitted_for_quest.emit(quest, plate)
	return is_correct


func submit_faxed_report(quest: Quest, plate: String) -> bool:
	var is_correct := submit_plate_to_quest(quest, plate)
	resolved_cases += 1
	if !is_correct:
		lawsuit_cases += 1
	case_statistics_changed.emit(resolved_cases, lawsuit_cases)
	return is_correct
