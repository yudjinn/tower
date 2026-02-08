class_name  TileGenerator
extends Node

var tile_pool: Array[GameTileData] = [
	preload("res://resources/tiles/straight.tres"),
	preload("res://resources/tiles/curve_road.tres"),
	preload("res://resources/tiles/t_junction.tres"),
]

func generate_options(count: int) -> Array[GameTileData]:
	var options: Array[GameTileData] = []
	for _i in range(count):
		options.append(tile_pool.pick_random())
	return options
