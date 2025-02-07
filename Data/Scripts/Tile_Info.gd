class_name Tile_Info extends Resource

@export var name: String = "Tile"
@export var source_id: int = -1
@export var atlas_coords:Vector2i = Vector2i(-1, -1)
##An id to represent the layer this tile will be place in
##-1 means layer dose not matter. The id depends on the generator, but
##usally the higher the id, the latter it is rendered
##so ground may be id of 0, grass 1, trees 2, and objects 3
##but it is up to the generator to repect this value
##NOTE: could also get the z from the tile set instead, but this is cleaner
##and wont mess up rendering
@export var layer_id: int = -1
@export var alternative_tile: int = 0
