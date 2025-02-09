class_name Foilage_Generator extends Generator_Data

@export var region_size : int = 8
@export var chunk_size : int = 8

@export var detail_map : Noise = FastNoiseLite.new()
@export var variation_map : Noise = FastNoiseLite.new()

##the tiled used for the null tile. Can be null or a default tile
@export var empty_tile : Tile_Info = null
##Represent how often the variation will be an empty tile
@export var emptiness : float = 0.5

@export var grass_set : Array[Tile_Info]
@export var tree_set : Array[Tile_Info]
@export var rock_set : Array[Tile_Info]

	
func pick_foliage(pos)->Tile_Info:
	
	var variation_roll = ((detail_map.get_noise_2d(pos.x,pos.y)+1)/2)*(1+emptiness)
	var random_roll = (variation_map.get_noise_2d(pos.x,pos.y)+1)*50
	
	#var variation_roll = (variation_map.get_noise_2d(pos.x,pos.y)+1)/2*(1+emptiness)
	#var random_roll = (detail_map.get_noise_2d(pos.x,pos.y)+1)*50
	if variation_roll > 1:
		return empty_tile
	if grass_set.size() > 0 && random_roll >= 50: #60:
		return grass_set[round((grass_set.size()-1)*variation_roll)]
	elif rock_set.size() > 0 && random_roll < 25:
		return rock_set[round((rock_set.size()-1)*variation_roll)]
	elif tree_set.size() > 0 && random_roll < 50:
		return tree_set[round((tree_set.size()-1)*variation_roll)]
	else:
		return empty_tile
		


func get_tile_info(coord : Vector2i)->Tile_Info:
	return pick_foliage(coord)
	
	
