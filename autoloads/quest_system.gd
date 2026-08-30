extends Node

var _active_quest: Quest
var resolved_cases := 0
var lawsuit_cases := 0
var total_cases := 0
var binned_cases := 0

var _report_states := {}
var _completion_check_queued := false
var _completion_emitted := false

const REPORT_OPEN := &"open"
const REPORT_BINNED := &"binned"
const REPORT_FAXED := &"faxed"

signal new_quest_assigned(quest: Quest)
signal plate_submitted_for_quest(quest: Quest, plate: String)
signal case_statistics_changed(resolved_cases: int, lawsuit_cases: int)
signal all_cases_completed(
	correct_cases: int,
	total_cases: int,
	resolved_cases: int,
	binned_cases: int
)


func reset_run() -> void:
	_active_quest = null
	resolved_cases = 0
	lawsuit_cases = 0
	total_cases = 0
	binned_cases = 0
	_report_states.clear()
	_completion_check_queued = false
	_completion_emitted = false
	case_statistics_changed.emit(resolved_cases, lawsuit_cases)


func reserve_cases(amount: int) -> void:
	total_cases += maxi(0, amount)


func register_report(report: CrimeReport3D, count_as_new_case := true) -> void:
	if !is_instance_valid(report):
		return

	var report_id := report.get_instance_id()
	if _report_states.has(report_id):
		return

	_report_states[report_id] = REPORT_OPEN
	if count_as_new_case:
		total_cases += 1


func mark_report_binned(report: CrimeReport3D) -> void:
	if !is_instance_valid(report):
		return

	var report_id := report.get_instance_id()
	if !_report_states.has(report_id):
		register_report(report)
	if _report_states.get(report_id) == REPORT_BINNED:
		return

	_report_states[report_id] = REPORT_BINNED
	binned_cases += 1
	_queue_completion_check()


func mark_report_removed_from_bin(report: CrimeReport3D) -> void:
	if !is_instance_valid(report):
		return

	var report_id := report.get_instance_id()
	if _report_states.get(report_id) != REPORT_BINNED:
		return

	_report_states[report_id] = REPORT_OPEN
	binned_cases = maxi(0, binned_cases - 1)

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
	if !quest:
		push_warning("Cannot submit a license plate without an associated quest.")
		return false

	var is_correct := compare_alphanumeric_only(plate, quest.correct_plate)
	if is_correct:
		print("CORRECT !!!!")
	else:
		print("wrong")
	plate_submitted_for_quest.emit(quest, plate)
	return is_correct


func compare_alphanumeric_only(first: String, second: String) -> bool:
	return get_alphanumeric_only(first) == get_alphanumeric_only(second)


func get_alphanumeric_only(input: String) -> String:
	var regex := RegEx.new()
	regex.compile(r"[^a-zA-Z0-9]")
	return regex.sub(input, "", true).to_lower()


func submit_faxed_report(report: CrimeReport3D, quest: Quest, plate: String) -> bool:
	if !is_instance_valid(report):
		return false

	var report_id := report.get_instance_id()
	if !_report_states.has(report_id):
		register_report(report)
	if _report_states.get(report_id) == REPORT_FAXED:
		return false
	if _report_states.get(report_id) == REPORT_BINNED:
		binned_cases = maxi(0, binned_cases - 1)

	var is_correct := submit_plate_to_quest(quest, plate)
	_report_states[report_id] = REPORT_FAXED
	resolved_cases += 1
	if !is_correct:
		lawsuit_cases += 1
	case_statistics_changed.emit(resolved_cases, lawsuit_cases)
	_queue_completion_check()
	return is_correct


func _queue_completion_check() -> void:
	if _completion_emitted or _completion_check_queued:
		return
	_completion_check_queued = true
	call_deferred("_check_for_completion")


func _check_for_completion() -> void:
	_completion_check_queued = false
	if _completion_emitted or total_cases == 0:
		return
	if resolved_cases + binned_cases != total_cases:
		return

	_completion_emitted = true
	var correct_cases := maxi(0, resolved_cases - lawsuit_cases)
	all_cases_completed.emit(
		correct_cases,
		total_cases,
		resolved_cases,
		binned_cases
	)
