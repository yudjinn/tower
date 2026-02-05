@abstract
class_name GridSystem extends RefCounted

@abstract
func cell_to_world(coords: Vector2i) -> Vector2

@abstract
func world_to_cell(world_pos: Vector2) -> Vector2i

@abstract
func get_neighbors(coords: Vector2i) -> Array[Vector2i]

@abstract
func get_edge_count() -> int

@abstract
func rotate_edges(edges: Array[bool], steps: int) -> Array[bool]

@abstract
func get_opposite_edge(edge: int) -> int

@abstract
func get_neighbor_on_edge(coords: Vector2i, edge: int) -> Vector2i
