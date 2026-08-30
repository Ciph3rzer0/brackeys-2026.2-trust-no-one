extends ReportHolder3D


func _ready() -> void:
	report_placed.connect(_on_report_placed)
	report_removed.connect(_on_report_removed)


func get_interaction_text(_player: Player) -> String:
	return "press e to place report in trash bin"


func _on_report_placed(report: CrimeReport3D, _slot: Node3D) -> void:
	QuestSystem.mark_report_binned(report)


func _on_report_removed(report: CrimeReport3D) -> void:
	QuestSystem.mark_report_removed_from_bin(report)
