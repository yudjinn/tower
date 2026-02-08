class_name PathFinder
extends RefCounted

var placed_tiles: Dictionary
var grid: SquareGrid

func _init(tiles: Dictionary, g: SquareGrid) -> void:
	placed_tiles = tiles
	grid = g

func calculate_path(from_cell: Vector2i) -> Array[Vector2i]:
	var queue: Array[Vector2i] = [from_cell]
	var came_from: Dictionary = {from_cell: null}

	while queue.size() > 0:
		var current = queue.pop_front()

		if current == Vector2i(0, 0):
			var path: Array[Vector2i] = []
			var step = current
			while step != null:
				path.append(step)
				step = came_from[step]
			path.reverse()
			return path

		var current_data = placed_tiles[current]
		for edge in grid.get_edge_count():
			var neighbor = grid.get_neighbor_on_edge(current, edge)
			if came_from.has(neighbor):
				continue
			if not placed_tiles.has(neighbor):
				continue
			var neighbor_data = placed_tiles[neighbor]
			var opposite = grid.get_opposite_edge(edge)
			if current_data.road_edges[edge] and neighbor_data.road_edges[opposite]:
				came_from[neighbor] = current
				queue.append(neighbor)

	return []

func path_to_waypoints(cell_path: Array[Vector2i]) -> Array[Vector2]:
	var waypoints: Array[Vector2] = []

	if cell_path.is_empty():
		return waypoints

	# Find the open edge on the first cell (the spawn tile)
	var spawn_cell = cell_path[0]
	var spawn_data = placed_tiles[spawn_cell]
	var spawn_center = grid.cell_to_world(spawn_cell)

	var edge_midpoints = [
		Vector2(grid.tile_w / 4, -grid.tile_h / 4),  # North
		Vector2(grid.tile_w / 4, grid.tile_h / 4),    # East
		Vector2(-grid.tile_w / 4, grid.tile_h / 4),   # South
		Vector2(-grid.tile_w / 4, -grid.tile_h / 4),  # West
	]
	var open_edges: Array[int] = []
	for edge in grid.get_edge_count():
		if spawn_data.road_edges[edge]:
			var neighbor = grid.get_neighbor_on_edge(spawn_cell, edge)
			if not placed_tiles.has(neighbor):
				open_edges.append(edge)

	if open_edges.size() > 0:
		var spawn_edge = open_edges.pick_random()
		waypoints.append(spawn_center + edge_midpoints[spawn_edge])


	# Then add cell centers for the rest of the path
	for cell in cell_path:
		waypoints.append(grid.cell_to_world(cell))

	return waypoints

func find_spawn_points(min_distance: int = 5) -> Array[Vector2i]:
	# BFS from Demon Lord, track distance
	var queue: Array[Vector2i] = [Vector2i(0, 0)]
	var distance: Dictionary = {Vector2i(0, 0): 0}

	while queue.size() > 0:
		var current = queue.pop_front()
		var current_data = placed_tiles[current]

		for edge in grid.get_edge_count():
			var neighbor = grid.get_neighbor_on_edge(current, edge)
			if distance.has(neighbor):
				continue
			if not placed_tiles.has(neighbor):
				continue
			var neighbor_data = placed_tiles[neighbor]
			var opposite = grid.get_opposite_edge(edge)
			if current_data.road_edges[edge] and neighbor_data.road_edges[opposite]:
				distance[neighbor] = distance[current] + 1
				queue.append(neighbor)

	# Find leaves (only 1 connected neighbor) at distance >= min_distance
	var spawn_points: Array[Vector2i] = []
	for cell in placed_tiles:
		if cell == Vector2i(0,0):
			continue
		if distance.get(cell, 0) < min_distance:
			continue
		var cell_data = placed_tiles[cell]
		for edge in grid.get_edge_count():
			if cell_data.road_edges[edge]:
				var neighbor = grid.get_neighbor_on_edge(cell, edge)
				if not placed_tiles.has(neighbor):
					spawn_points.append(cell)
					break

	return spawn_points
