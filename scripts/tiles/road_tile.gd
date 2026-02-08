extends Node2D

var tile_data: GameTileData
var rotation_steps: int = 0
var is_demon_lord: bool = false

# Using square grid
@onready
var grid = SquareGrid.new()

func setup(data: GameTileData, rot: int):
	tile_data = data
	rotation_steps = rot
	is_demon_lord = data.tile_name == "Demon Lord"
	queue_redraw()

func _draw() -> void:
	# Diamond outline
	var corners = [
		Vector2(0, -(grid.tile_h / 2)), #top
		Vector2((grid.tile_w / 2), 0), #right
		Vector2(0, (grid.tile_h / 2)), # bottom
		Vector2(-(grid.tile_w / 2), 0) # left
	]

	draw_polyline(corners + [corners[0]], Color.WHITE, 2.0)

	# Edge midpoints
	var edge_midpoints = [
		Vector2((grid.tile_w / 4), -(grid.tile_h / 4)), # top-right
		Vector2((grid.tile_w / 4), (grid.tile_h / 4)), # bottom-right
		Vector2(-(grid.tile_w / 4), (grid.tile_h / 4)), # bottom-left
		Vector2(-(grid.tile_w / 4), -(grid.tile_h / 4)) # top-left
	]

	for i in tile_data.road_edges.size():
		if tile_data.road_edges[i]:
			draw_line(Vector2.ZERO, edge_midpoints[i], Color.YELLOW, 4.0)

	for slot in tile_data.tower_slots:
		var pos = Vector2(slot.local_offset) * 16 #scale to offset pixels
		draw_circle(pos, 6.0, Color.RED)
		# Direction indicator
		var facing_dir = edge_midpoints[slot.facing_edge].normalized() * 12
		draw_line(pos, pos + facing_dir, Color.RED, 2.0)

	if is_demon_lord:
		var size = Vector2(20,20)
		draw_rect(Rect2(-size / 2, size), Color.PURPLE)
