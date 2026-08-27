@tool
extends EditorPlugin
## Shift-click a PathNode2D, then shift-click a second one, to connect them.
## Shift-click the same pair again to disconnect. Ordinary click-drag still
## moves nodes normally — this only intercepts shift+left-click.
##
## _handles() returns true unconditionally as a workaround for
## godotengine/godot#103071 (forward_canvas_gui_input stops firing once
## multiple nodes are selected, unless _handles always returns true).
## Because of that, selection is tracked directly via EditorSelection
## rather than through _edit().

const PICK_RADIUS := 14.0

var _graph: AStarGraph2D
var _pending: PathNode2D
var _last_local_mouse: Vector2

func _enter_tree() -> void:
	get_editor_interface().get_selection().selection_changed.connect(_on_selection_changed)

func _exit_tree() -> void:
	get_editor_interface().get_selection().selection_changed.disconnect(_on_selection_changed)

func _on_selection_changed() -> void:
	_graph = null
	_pending = null
	var selected := get_editor_interface().get_selection().get_selected_nodes()
	print("[astar_graph_editor] selection changed -> ", selected)
	for node in selected:
		var found := _find_graph_ancestor(node)
		if found:
			_graph = found
			break
	print("[astar_graph_editor] resolved graph -> ", _graph)

func _handles(_object: Object) -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if not visible:
		_pending = null

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if not _graph:
		return false

	if event is InputEventMouseMotion:
		_last_local_mouse = (_graph.make_input_local(event) as InputEventMouseMotion).position
		if _pending:
			update_overlays()
		return false

	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			print("[astar_graph_editor] left click, shift=", mb.shift_pressed, " graph=", _graph)
			if mb.shift_pressed:
				var local_pos: Vector2 = (_graph.make_input_local(event) as InputEventMouseButton).position
				var clicked := _find_node_near(local_pos)
				print("[astar_graph_editor] local_pos=", local_pos, " clicked=", clicked)
				if clicked:
					_handle_click(clicked)
					update_overlays()
					return true  # consume — don't let this shift-click also select/drag

	return false

func _forward_canvas_draw_over_viewport(overlay: Control) -> void:
	if not _graph or not _pending:
		return
	var xform := _graph.get_global_transform_with_canvas()
	var pending_screen: Vector2 = xform * _pending.position
	var mouse_screen: Vector2 = xform * _last_local_mouse
	overlay.draw_arc(pending_screen, 10.0, 0, TAU, 24, Color.MAGENTA, 3.0)
	overlay.draw_line(pending_screen, mouse_screen, Color.MAGENTA, 2.0)

func _find_node_near(local_pos: Vector2) -> PathNode2D:
	var closest: PathNode2D = null
	var closest_dist := PICK_RADIUS
	var candidates := _graph.find_children("*", "PathNode2D", true, false)
	print("[astar_graph_editor] candidates=", candidates.size())
	for node in candidates:
		var path_node := node as PathNode2D
		var node_local: Vector2 = _graph.to_local(path_node.global_position)
		var dist: float = local_pos.distance_to(node_local)
		print("[astar_graph_editor]   ", path_node.name, " at ", node_local, " dist=", dist)
		if dist <= closest_dist:
			closest = path_node
			closest_dist = dist
	return closest

func _find_graph_ancestor(node: Node) -> AStarGraph2D:
	var current := node
	while current:
		if current is AStarGraph2D:
			return current
		current = current.get_parent()
	return null

func _handle_click(clicked: PathNode2D) -> void:
	if _pending == null:
		_pending = clicked
		return
	if _pending == clicked:
		_pending = null  # clicked the same node twice -> cancel
		return

	if _has_connection(_pending, clicked):
		_remove_connection(_pending, clicked)
	else:
		_add_connection(_pending, clicked)
	_pending = null

func _has_connection(a: PathNode2D, b: PathNode2D) -> bool:
	for p in a.connections:
		if a.get_node_or_null(p) == b:
			return true
	return false

func _add_connection(a: PathNode2D, b: PathNode2D) -> void:
	var new_conns := a.connections.duplicate()
	new_conns.append(a.get_path_to(b))

	var undo := get_undo_redo()
	undo.create_action("Connect %s -> %s" % [a.name, b.name])
	undo.add_do_property(a, "connections", new_conns)
	undo.add_undo_property(a, "connections", a.connections.duplicate())
	undo.commit_action()

func _remove_connection(a: PathNode2D, b: PathNode2D) -> void:
	var new_conns := a.connections.duplicate()
	for i in new_conns.size():
		if a.get_node_or_null(new_conns[i]) == b:
			new_conns.remove_at(i)
			break

	var undo := get_undo_redo()
	undo.create_action("Disconnect %s -> %s" % [a.name, b.name])
	undo.add_do_property(a, "connections", new_conns)
	undo.add_undo_property(a, "connections", a.connections.duplicate())
	undo.commit_action()
