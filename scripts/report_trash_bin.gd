extends ReportHolder3D

@onready var pin_sound: AudioStreamPlayer3D = $PinSound
@onready var unpin_sound: AudioStreamPlayer3D = $UnpinSound

var _report_stack: Array[CrimeReport3D] = []


func _ready() -> void:
	report_placed.connect(_on_report_placed)
	report_removed.connect(_on_report_removed)


func can_interact(player: Player) -> bool:
	if !player:
		return false
	if player.has_held_report():
		return can_accept_report()
	return _get_most_recent_report() != null


func get_interaction_text(player: Player) -> String:
	if player and player.has_held_report():
		return "press e to place report"
	return "press e to take report"


func interact(player: Player = null) -> void:
	if !player:
		player = GameManager.player
	if !player:
		return

	if player.has_held_report():
		player.place_held_report(self)
		return

	var report := _get_most_recent_report()
	if report:
		player.pick_up_report(report)


func _on_report_placed(report: CrimeReport3D, _slot: Node3D) -> void:
	pin_sound.play()
	_report_stack.erase(report)
	_report_stack.append(report)
	# Let the bin receive the interaction ray instead of buried reports.
	report.collision_layer = 0
	report.collision_mask = 0
	QuestSystem.mark_report_binned(report)


func _on_report_removed(report: CrimeReport3D) -> void:
	unpin_sound.play()
	_report_stack.erase(report)
	QuestSystem.mark_report_removed_from_bin(report)


func _get_most_recent_report() -> CrimeReport3D:
	while !_report_stack.is_empty():
		var report: CrimeReport3D = _report_stack.back()
		if is_instance_valid(report) and report.current_holder == self:
			return report
		_report_stack.pop_back()
	return null
