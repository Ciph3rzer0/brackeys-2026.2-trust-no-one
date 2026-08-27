extends Area2D

@export var camera_name: String

func _ready() -> void:
	assert(camera_name)


func _on_body_entered(body: Node2D) -> void:
	print("Camera ", camera_name, " sees ", body.name)
	$ALERT.visible = true


func _on_body_exited(_body: Node2D) -> void:
	$ALERT.visible = false
