extends Node3D

@onready var stats_label: Label3D = $StatsLabel

var _displayed_counts := Vector4i(-1, -1, -1, -1)


func _process(_delta: float) -> void:
	var unresolved_cases := 0
	var trash_bin_cases := 0

	for node in get_tree().get_nodes_in_group("CrimeReport"):
		var report := node as CrimeReport3D
		if !is_instance_valid(report) or report.is_queued_for_deletion():
			continue

		unresolved_cases += 1
		if report.current_holder and report.current_holder.is_in_group("ReportTrashBin"):
			trash_bin_cases += 1

	var counts := Vector4i(
		QuestSystem.resolved_cases,
		unresolved_cases,
		trash_bin_cases,
		QuestSystem.lawsuit_cases
	)
	if counts == _displayed_counts:
		return

	_displayed_counts = counts
	stats_label.text = (
		"Resolved cases: %d\n"
		+ "Unresolved cases: %d\n"
		+ "Trash bin cases: %d\n"
		+ "Cases resulting in lawsuits: %d"
	) % [counts.x, counts.y, counts.z, counts.w]
