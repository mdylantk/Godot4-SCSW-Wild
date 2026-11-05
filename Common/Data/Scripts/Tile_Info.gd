class_name Tile_Info extends Resource

@export var name: String = "Tile"
@export var source_id: int = -1
@export var atlas_coords:Vector2i = Vector2i(-1, -1)
#below is for tiles that are diffrent around the edges
#(ideally to be used with transparent edges)
@export var connection:Array[int] #= [
	#0, 0, 20, 20, 0, 0, 20, 20, 1, 1, 16, 16, 1, 1, 21, 21, 0, 0, 20, 20, 0,
	 #0, 20, 20, 1, 1, 16, 16, 1, 1, 21, 21, 4, 4, 12, 12, 4, 4, 12, 12, 8, 8,
	 #10, 10, 8, 8, 24, 24, 4, 4, 12, 12, 4, 4, 12, 12, 5, 5, 32, 32, 5, 5, 13,
	 #13, 0, 0, 20, 20, 0, 0, 20, 20, 1, 1, 16, 16, 1, 1, 21, 21, 0, 0, 20, 20,
	 #0, 0, 20, 20, 1, 1, 16, 16, 1, 1, 21, 21, 4, 4, 12, 12, 4, 4, 12, 12, 8,
	 #8, 10, 10, 8, 8, 24, 24, 4, 4, 12, 12, 4, 4, 12, 12, 5, 5, 32, 32, 5, 5,
	 #13, 13, 3, 3, 17, 23, 3, 3, 17, 23, 2, 2, 18, 34, 2, 2, 35, 22, 3, 3, 17,
	 #23, 3, 3, 17, 23, 2, 2, 18, 34, 2, 2, 35, 22, 9, 9, 19, 25, 9, 9, 19, 25,
	 #11, 11, 46, 30, 11, 11, 31, 41, 9, 9, 19, 25, 9, 9, 19, 25, 27, 27, 39,
	 #44, 27, 27, 43, 29, 3, 3, 17, 23, 3, 3, 17, 23, 2, 2, 18, 34, 2, 2, 35,
	 #22, 3, 3, 17, 23, 3, 3, 17, 23, 2, 2, 18, 34, 2, 2, 35, 22, 7, 7, 33, 15,
	 #7, 7, 33, 15, 26, 26, 38, 42, 26, 26, 45, 28, 7, 7, 33, 15, 7, 7, 33, 15,
	 #6, 6, 40, 36, 6, 6, 37, 14]
##An id to represent the layer this tile will be place in
##-1 means layer dose not matter. The id depends on the generator, but
##usally the higher the id, the latter it is rendered
##so ground may be id of 0, grass 1, trees 2, and objects 3
##but it is up to the generator to repect this value
##NOTE: could also get the z from the tile set instead, but this is cleaner
##and wont mess up rendering
@export var layer_id: int = -1
@export var alternative_tile: int = 0
