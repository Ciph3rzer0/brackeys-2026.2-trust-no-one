class_name ReportHolder3D
extends StaticBody3D

signal report_placed(report: CrimeReport3D, slot: Node3D)
signal report_removed(report: CrimeReport3D)

@export var holder_label := "holder"
@export var slot_container_path := NodePath("Slots")

func get_first_open_slot() -> Node3D:
	var slot_container := get_node_or_null(slot_container_path)
	if !slot_container:
		return null

	for child in slot_container.get_children():
		var slot := child as Node3D
		if slot and get_report_in_slot(slot) == null:
			return slot

	return null

func get_report_in_slot(slot: Node3D) -> CrimeReport3D:
	for child in slot.get_children():
		if child is CrimeReport3D:
			return child as CrimeReport3D
	return null

func can_accept_report() -> bool:
	return get_first_open_slot() != null

func can_interact(player: Player) -> bool:
	return player != null and player.has_held_report() and can_accept_report()

func get_interaction_text(_player: Player) -> String:
	return "press e to place report on %s" % holder_label

func interact(player: Player = null) -> void:
	if !player:
		player = GameManager.player
	if player:
		player.place_held_report(self)

func place_report(report: CrimeReport3D) -> bool:
	var open_slot := get_first_open_slot()
	if !open_slot:
		return false
	return place_report_in_slot(report, open_slot)


func place_report_in_slot(report: CrimeReport3D, slot: Node3D) -> bool:
	if !report or !slot:
		return false

	var slot_container := get_node_or_null(slot_container_path)
	if !slot_container or slot.get_parent() != slot_container:
		return false
	if get_report_in_slot(slot) != null:
		return false

	if report.current_holder and report.current_holder != self:
		report.current_holder.remove_report(report)

	report.reparent(slot, false)
	report.global_transform = slot.global_transform.orthonormalized()
	report.current_holder = self
	report.set_held(false)
	report_placed.emit(report, slot)
	return true

func remove_report(report: CrimeReport3D) -> void:
	if report and report.current_holder == self:
		report.current_holder = null
		report_removed.emit(report)
