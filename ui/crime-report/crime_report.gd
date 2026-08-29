extends Control

@export var quest: Quest: set = set_quest
@export var follow_assigned_quests := true

func _ready() -> void:
	set_quest(quest)
	if follow_assigned_quests:
		QuestSystem.new_quest_assigned.connect(_on_new_quest_assigned)

func _on_new_quest_assigned(quest: Quest):
	set_quest(quest)

func set_quest(_quest: Quest):
	if !_quest: return
	quest = _quest
	
	if is_node_ready():
		%Time.text = DateHelper.month_day_time(quest.datetime_start_unix)
		if quest.datetime_start_unix > 0:
			%TimeEnd.visible = true
			%TimeEnd.text = DateHelper.month_day_time(quest.datetime_end_unix)
		else:
			%TimeEnd.visible = false
		
		%Incident.text = quest.incident
		%Details.text = quest.details

func _on_submit_button_pressed() -> void:
	var plate = %PlateEntryTextEdit.text
	QuestSystem.submit_plate_to_quest(quest, plate)
	print("Submitted ", plate)

func _on_plate_entry_text_edit_text_submitted(_new_text: String) -> void:
	_on_submit_button_pressed()
	#%PlateEntryTextEdit.grab_focus()

func get_plate_entry() -> String:
	return %PlateEntryTextEdit.text
