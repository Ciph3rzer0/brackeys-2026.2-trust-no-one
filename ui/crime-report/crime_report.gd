extends Control

@export var quest: Quest: set = set_quest
@export var follow_assigned_quests := true

@onready var plate_entry: LineEdit = %PlateEntryTextEdit

var _is_normalizing_plate_entry := false


func _ready() -> void:
	set_quest(quest)
	_normalize_plate_entry(plate_entry.text)
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


func set_report_number(report_number: int) -> void:
	%Header.text = "Crime Report #%d" % report_number if report_number > 0 else "Crime Report"

func _on_submit_button_pressed() -> void:
	var plate := get_plate_entry()
	if plate.strip_edges().is_empty():
		%PlateEntryStatus.add_theme_color_override("font_color", Color(0.7, 0.04, 0.04))
		%PlateEntryStatus.text = "Enter a license plate before finishing."
		%PlateEntryStatus.show()
		return

	QuestSystem.submit_plate_to_quest(quest, plate)
	print("Submitted ", plate)
	plate_entry.release_focus()
	%PlateEntryStatus.add_theme_color_override("font_color", Color(0.18, 0.42, 0.2))
	%PlateEntryStatus.text = "Plate entry complete — use WASD to stand."
	%PlateEntryStatus.show()

func _on_plate_entry_text_edit_text_submitted(_new_text: String) -> void:
	_on_submit_button_pressed()
	#%PlateEntryTextEdit.grab_focus()


func _on_plate_entry_text_changed(new_text: String) -> void:
	%PlateEntryStatus.hide()
	_normalize_plate_entry(new_text)


func _normalize_plate_entry(value: String) -> void:
	if _is_normalizing_plate_entry:
		return

	var uppercase_value := value.to_upper()
	if value == uppercase_value:
		return

	_is_normalizing_plate_entry = true
	var previous_caret_column := plate_entry.caret_column
	plate_entry.text = uppercase_value
	plate_entry.caret_column = mini(previous_caret_column, uppercase_value.length())
	_is_normalizing_plate_entry = false


func get_plate_entry() -> String:
	return plate_entry.text.to_upper()
