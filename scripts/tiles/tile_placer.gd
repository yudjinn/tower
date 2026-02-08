extends Node2D

var grid: SquareGrid
var current_tile: GameTileData
var rotation_steps: int = 0
var is_placing: bool = false
var hover_cell: Vector2i
var placed_tiles: Dictionary[Vector2i, GameTileData] = {}
var path_finder: PathFinder

# References
var tile_container: Node2D

func _ready() -> void:
	grid = SquareGrid.new()
	tile_container = get_node("../GameBoard/TileContainer")
	GameEvents.tile_drafted.connect(_on_tile_drafted)
	GameEvents.phase_changed.connect(_on_phase_changed)
	var demon_lord = preload("res://resources/tiles/demon_lord.tres")
	placed_tiles[Vector2i(0,0)] = demon_lord
	var road_tile = preload("res://scenes/tiles/road_tile.tscn").instantiate()
	road_tile.setup(demon_lord, 0)
	road_tile.position = grid.cell_to_world(Vector2i(0,0))
	path_finder = PathFinder.new(placed_tiles, grid)
	tile_container.add_child(road_tile)


func _input(event: InputEvent) -> void:
	if not is_placing:
		return

	if event is InputEventMouseMotion:
		hover_cell = grid.world_to_cell(get_global_mouse_position())
		queue_redraw()

	elif event is  InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			rotation_steps = (rotation_steps + 1) % grid.get_edge_count()
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_valid_placement(hover_cell):
				place_tile(hover_cell)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			is_placing = false
			GameEvents.tile_placement_cancelled.emit()

func is_valid_placement(cell: Vector2i) -> bool:
	# Cell must be empty
	if placed_tiles.has(cell):
		return false

	# Check adjacent tiles for a matching road connection
	for edge in grid.get_edge_count():
		var neighbor = grid.get_neighbor_on_edge(cell, edge)
		if placed_tiles.has(neighbor):
			var rotated_edges = grid.rotate_edges(current_tile.road_edges, rotation_steps)
			var neighbor_tile: GameTileData = placed_tiles[neighbor]
			var opposite = grid.get_opposite_edge(edge)
			# Both sides of the connection must have road
			if rotated_edges[edge] and neighbor_tile.road_edges[opposite]:
				return true

	return false

func place_tile(cell: Vector2i):
	# Apply rotation to tile data
	var rotated_data = current_tile.duplicate()
	rotated_data.road_edges = grid.rotate_edges(current_tile.road_edges, rotation_steps)
	for slot in rotated_data.tower_slots:
		slot.facing_edge = (slot.facing_edge + rotation_steps) % grid.get_edge_count()

	# store in dict
	placed_tiles[cell] = rotated_data

	# Instantiate the visual tile
	var road_tile = preload("res://scenes/tiles/road_tile.tscn").instantiate()
	road_tile.setup(rotated_data, rotation_steps)
	road_tile.position = grid.cell_to_world(cell)
	tile_container.add_child(road_tile)
	# After adding the road_tile to tile_container
	var archer_tower_scene = preload("res://scenes/towers/archer_tower.tscn")
	for slot in rotated_data.tower_slots:
		var tower = archer_tower_scene.instantiate()

		# Position: tile world pos + offset
		var offset = Vector2(slot.local_offset) * 16
		tower.position = grid.cell_to_world(cell) + offset

		tower.setup(slot.tower_type, slot.facing_edge )
		tile_container.add_child(tower)


	# Reset State
	is_placing = false
	rotation_steps = 0

	# Notify bus
	GameEvents.tile_placed.emit(cell, rotated_data, rotation_steps)

func _draw():
	if not is_placing or current_tile == null:
		return

	var world_pos = grid.cell_to_world(hover_cell)
	draw_set_transform(world_pos)
	var valid = is_valid_placement(hover_cell)
	var color = Color.GREEN if valid else Color.RED
	color.a = 0.5

	var rotated_edges = grid.rotate_edges(current_tile.road_edges, rotation_steps)

	# Diamond outline
	var corners = [
		Vector2(0, -(grid.tile_h / 2)), #top
		Vector2((grid.tile_w / 2), 0), #right
		Vector2(0, (grid.tile_h / 2)), # bottom
		Vector2(-(grid.tile_w / 2), 0) # left
	]
	draw_polyline(corners + [corners[0]], color, 2.0)

	var edge_midpoints = [
		Vector2((grid.tile_w / 4), -(grid.tile_h / 4)), # top-right
		Vector2((grid.tile_w / 4), (grid.tile_h / 4)), # bottom-right
		Vector2(-(grid.tile_w / 4), (grid.tile_h / 4)), # bottom-left
		Vector2(-(grid.tile_w / 4), -(grid.tile_h / 4)) # top-left
	]
	for i in rotated_edges.size():
		if rotated_edges[i]:
			draw_line(Vector2.ZERO, edge_midpoints[i], color, 4.0)

	for slot in current_tile.tower_slots:
		var offset = slot.local_offset
		for i in rotation_steps:
			offset = Vector2i(offset.y, -offset.x)
		var pos = Vector2(offset) * 16 #scale to offset pixels
		draw_circle(pos, 6.0, Color.RED)
		# Direction indicator
		var rotated_facing = (slot.facing_edge + rotation_steps) % grid.get_edge_count()
		var facing_dir = edge_midpoints[rotated_facing].normalized() * 12
		draw_line(pos, pos + facing_dir, color, 2.0)


func _on_tile_drafted(tile_data):
	current_tile = tile_data
	rotation_steps = 0
	is_placing = true

func _on_phase_changed(phase):
	if phase != GameEvents.GamePhase.PLACE:
		is_placing = false
		queue_redraw()
