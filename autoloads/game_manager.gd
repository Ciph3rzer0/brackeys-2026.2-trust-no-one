extends Node

var _player: Player

func set_player(player: Player):
	assert(!_player)
	_player = player

func _ready() -> void:
	if _player:
		print("PLAYER IS ", _player.name)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Q:
			QuestSystem.assign_new_quest()
			get_viewport().set_input_as_handled()
