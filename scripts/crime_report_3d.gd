class_name CrimeReport3D
extends StaticBody3D

@export var quest: Quest:
	set(value):
		quest = value
		if is_node_ready():
			_apply_quest()

var current_holder: ReportHolder3D

@onready var report_sprite: Sprite3D = $Sprite3D
@onready var report_viewport: SubViewport = $SubViewport
@onready var report_ui: Control = $SubViewport/CrimeReport

func _ready() -> void:
	report_sprite.texture = report_viewport.get_texture()
	_apply_quest()

func _apply_quest() -> void:
	if quest and report_ui.has_method("set_quest"):
		report_ui.set_quest(quest)

func can_interact(player: Player) -> bool:
	return player != null and !player.has_held_report()

func get_interaction_text(_player: Player) -> String:
	return "press e to pick up report"

func interact(player: Player = null) -> void:
	if !player:
		player = GameManager.player
	if player:
		player.pick_up_report(self)

func set_held(is_held: bool) -> void:
	collision_layer = 0 if is_held else 1
	collision_mask = 0 if is_held else 1

func get_report_title() -> String:
	if quest and !quest.incident.is_empty():
		return quest.incident
	return name
