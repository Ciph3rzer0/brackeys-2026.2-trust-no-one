extends CanvasLayer

@onready var overlay: Control = %Overlay
@onready var result_label: Label = %ResultLabel
@onready var score_label: Label = %ScoreLabel
@onready var message_label: Label = %MessageLabel
@onready var play_again_button: Button = %PlayAgainButton

var _is_displayed := false


func _ready() -> void:
	# Keep the overlay visible in the 2D editor for layout work, but hidden
	# during gameplay until every case has been completed.
	overlay.hide()
	QuestSystem.all_cases_completed.connect(_on_all_cases_completed)


func _on_all_cases_completed(
	correct_cases: int,
	total_cases: int,
	resolved_cases: int,
	binned_cases: int
) -> void:
	if _is_displayed:
		return
	_is_displayed = true

	var correct_fraction := float(correct_cases) / float(maxi(1, total_cases))
	var correct_percent := roundi(correct_fraction * 100.0)
	score_label.text = (
		"Final score: %d / %d cases correct (%d%%)\nFaxed: %d    Trash bin: %d"
		% [
			correct_cases,
			total_cases,
			correct_percent,
			resolved_cases,
			binned_cases,
		]
	)

	if correct_fraction > 0.70:
		result_label.text = "Great job!"
		result_label.add_theme_color_override("font_color", Color("8bd49c"))
		message_label.text = (
			"You get to keep your job! I'll see you in the next town "
			+ "(at the next game jam)."
		)
	elif correct_fraction >= 0.20:
		result_label.text = "Decent job!"
		result_label.add_theme_color_override("font_color", Color("e8c878"))
		message_label.text = (
			"You can take Gloria's job. Make a copy of this pension denial form and "
			+ "mail it to Gloria's caretaker by EOD. Try to get my signature right "
			+ "if you want to keep working here."
		)
	else:
		result_label.text = "Bad job!"
		result_label.add_theme_color_override("font_color", Color("ec8989"))
		message_label.text = (
			"Your firing goes without saying. Further, I do not like our lawyers "
			+ "getting too rusty, so you will also be the target of a frivolous lawsuit "
			+ "filed in one of those districts without anti-SLAPP legislation. I'm on "
			+ "my way to Tobago... Gloria will explain the details."
		)

	overlay.show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	play_again_button.grab_focus()


func _on_play_again_button_pressed() -> void:
	play_again_button.disabled = true
	get_tree().paused = false
	QuestSystem.reset_run()
	var reload_error := get_tree().reload_current_scene()
	if reload_error != OK:
		push_error("Could not restart the game. Error code: %d" % reload_error)
