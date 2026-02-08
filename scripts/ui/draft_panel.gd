extends Control

var draft_manager: Node
var options: Array[GameTileData] = []

func _ready():
	draft_manager = get_node("/root/Main/DraftManager")
	GameEvents.draft_options_ready.connect(_on_options_ready)
	GameEvents.phase_changed.connect(_on_phase_changed)
	visible = false

func _on_options_ready(new_options) -> void:
	options = new_options
	visible = true
	queue_redraw()

func _on_phase_changed(new_phase: GameEvents.GamePhase) -> void:
	if new_phase == GameEvents.GamePhase.DRAFT:
		visible = true
	else:
		visible = false
	queue_redraw()

func _draw() -> void:
	if options.is_empty():
		return

	var box_size = Vector2(140,100)
	var spacing = 20.0
	var total_width = box_size.x * 3 + spacing * 2
	var start_x = (get_size().x - total_width) / 2
	var start_y = (get_size().y - box_size.y) / 2

	for i in options.size():
		var pos = Vector2(start_x + i * (box_size.x + spacing), start_y)
		# var tile = options[i]
		# draw_texture(tile.texture, pos)
		draw_rect(Rect2(pos, box_size), Color(0.2, 0.2, 0.2, 0.8))
		draw_rect(Rect2(pos, box_size), Color.WHITE, false, 2.0)

		draw_string(ThemeDB.fallback_font, pos + Vector2(10,20), options[i].tile_name, HORIZONTAL_ALIGNMENT_LEFT)

		var center = pos + box_size / 2 + Vector2(0, 10)
		var scale_factor = 0.5
		var half_w = 64 * scale_factor
		var half_h = 32 * scale_factor

		var corners = [
			center + Vector2(0, -half_h),
			center + Vector2(half_w, 0),
			center + Vector2(0, half_h),
			center + Vector2(-half_w, 0),
		]
		draw_polyline(corners + [corners[0]], Color.WHITE, 1.5)

		# Road lines
		var edge_midpoints = [
			Vector2(half_w / 2, -half_h / 2),
			Vector2(half_w / 2, half_h / 2),
			Vector2(-half_w / 2, half_h / 2),
			Vector2(- half_w / 2, -half_h / 2),
		]
		for e in options[i].road_edges.size():
			if options[i].road_edges[e]:
				draw_line(center, center + edge_midpoints[e], Color.YELLOW, 2.0)

func _gui_input(event: InputEvent) -> void:
	if not visible or options.is_empty():
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var box_size = Vector2(140, 100)
		var spacing = 20.0
		var total_width = box_size.x * 3 + spacing * 2
		var start_x = (get_size().x - total_width) / 2
		var start_y = (get_size().y - box_size.y) / 2

		for i in range(3):
			var rect = Rect2(
				Vector2(start_x + i * (box_size.x + spacing), start_y),
				box_size
				)
			if rect.has_point(event.position):
				draft_manager.select_tile(i)
				break
