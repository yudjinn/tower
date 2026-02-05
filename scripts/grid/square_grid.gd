class_name SquareGrid
extends GridSystem
var tile_w: int = 128
var tile_h: int = 64

func cell_to_world(coords: Vector2i) -> Vector2:
	var x = (coords.x - coords.y) * (tile_w / 2)
	var y = (coords.x + coords.y) * (tile_h / 2)
	return Vector2(x, y)

func world_to_cell(world_pos: Vector2) -> Vector2i:
	var x = (world_pos.x / (tile_w / 2) + world_pos.y / (tile_h / 2)) / 2
	var y = (world_pos.y / (tile_h / 2) - world_pos.x / (tile_w / 2)) / 2
	return Vector2i(roundi(x), roundi(y))

func get_neighbors(coords: Vector2i) -> Array[Vector2i]:
	# get_neighbors(coords)[edge] gives you the neighbor on that edge
	return [
		coords + Vector2i(0,-1), # North
		coords + Vector2i(1,0), # East
		coords + Vector2i(0,1), # South
		coords + Vector2i(-1,0), # West
	]

func get_edge_count() -> int:
	return 4

func rotate_edges(edges: Array[bool], steps: int) -> Array[bool]:
	var size = edges.size()
	var rotated: Array[bool] = []
	rotated.resize(size)
	for i in size:
		rotated[(i + steps) % size] = edges[i]
	return rotated

func get_opposite_edge(edge: int) -> int:
	var edges = get_edge_count()
	return (edge + edges / 2) % edges

func get_neighbor_on_edge(coords: Vector2i, edge: int) -> Vector2i:
		return get_neighbors(coords)[edge]
