extends Node2D

var grid: SquareGrid
var current_tile: TileData
var rotation_steps: int = 0
var is_placing: bool = false
var hover_cell: Vector2i
var placed_tiles: Dictionary[Vector2i, TileData] = {}

# References
var tile_container: Node2D

func _ready() -> void:
	grid = SquareGrid.new()
	tile_container = get_node("../GameBoard/TileContainer")
	GameEvents.tile_drafted.connect(_on_tile_drafted)
	GameEvents.phase_changed.connect(_on_phase_changed)
	
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
			var neighbor_tile: TileData = placed_tiles[neighbor]
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
		slot.facing_edge = (slot.facing_edge + rotation_steps) % grid.edge_count()
	
	# store in dict
	placed_tiles[cell] = rotated_data
	
	# Instantiate the visual tile
	var road_tile = preload("res://scenes/tiles/road_tile.tscn").instantiate()
	road_tile.setup(rotated_data, rotation_steps)
	road_tile.position = grid.cell_to_world(cell)
	tile_container.add_child(road_tile)
	
	# Reset State
	is_placing = false
	rotation_steps = 0
	
	# Notify bus
	GameEvents.tile_placed.emit(cell, rotated_data, rotation_steps)

func _on_tile_drafted():
	pass
	
func _on_phase_changed():
	pass
