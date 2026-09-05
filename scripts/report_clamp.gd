extends ReportHolder3D

signal was_interacted_with()

@onready var report_sound: AudioStreamPlayer3D = $ReportSound


func _ready() -> void:
	report_placed.connect(_on_report_placed)
	report_removed.connect(_on_report_removed)


func _on_report_placed(_report: CrimeReport3D, _slot: Node3D) -> void:
	was_interacted_with.emit()
	report_sound.play()


func _on_report_removed(_report: CrimeReport3D) -> void:
	was_interacted_with.emit()
	report_sound.play()
