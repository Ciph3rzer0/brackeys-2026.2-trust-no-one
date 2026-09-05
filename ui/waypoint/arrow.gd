extends Control

@export var arrow_color: Color = Color.ORANGE
@export var arrow_length: float = 40.0
@export var arrow_width: float = 16.0

func _draw() -> void:
	# Shift everything left by half the length so (0,0) is the center pivot point
	var half_len: float = arrow_length / 2.0
	
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(-half_len, -arrow_width / 2.0),
		Vector2(arrow_length * 0.1, -arrow_width / 2.0),
		Vector2(arrow_length * 0.1, -arrow_width),
		Vector2(half_len, 0), # The tip is now at positive half_len
		Vector2(arrow_length * 0.1, arrow_width),
		Vector2(arrow_length * 0.1, arrow_width / 2.0),
		Vector2(-half_len, arrow_width / 2.0)
	])
	
	# Draw filled arrow
	draw_polygon(points, PackedColorArray([arrow_color]))
	
	# Draw outline
	var outline_points: PackedVector2Array = points
	outline_points.append(points[0]) # Close the loop properly
	draw_polyline(outline_points, Color.BLACK, 1.5, true)
