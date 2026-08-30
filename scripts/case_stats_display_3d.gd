extends Node3D

@onready var stats_label: Label3D = $StatsLabel

var _displayed_counts := Vector4i(-1, -1, -1, -1)


func _process(_delta: float) -> void:
	var unresolved_cases := maxi(
		0,
		QuestSystem.total_cases - QuestSystem.resolved_cases
	)
	var trash_bin_cases := QuestSystem.binned_cases

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
