class_name GameTileData
extends Resource

@export var tile_name: String
# This is dependent on the grid shape
@export var road_edges: Array[bool] = [false, false, false, false]
# Each entry is a dict of:
## local_offset: Vector2i
## tower_type: TowerType
## facing_edge: int
@export var tower_slots: Array[TowerSlot] = []
