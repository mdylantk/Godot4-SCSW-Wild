class_name Foilage_Generator extends Generator_Data

@export var detail_map : Noise = FastNoiseLite.new()
@export var variation_map : Noise = FastNoiseLite.new()

##the tiled used for the null tile. Can be null or a default tile
@export var empty_tile : Tile_Info = null
##Represent how often the variation will be an empty tile
@export var emptiness : float = 0.5

@export var grass_weight: int = 50
@export var grass_set : Array[Tile_Info]
@export var tree_weight: int = 50
@export var tree_set : Array[Tile_Info]
@export var rock_weight: int = 25
@export var rock_set : Array[Tile_Info]
	
func pick_foliage(pos)->Tile_Info:
	
	var variation_roll = ((detail_map.get_noise_2d(pos.x,pos.y)+1)/2)*(1+emptiness)
	var total_weight = grass_weight + tree_weight + rock_weight
	var random_roll = (variation_map.get_noise_2d(pos.x,pos.y)+1)/2*total_weight

	if variation_roll > 1:
		return empty_tile
		
	if grass_set.size() > 0 && random_roll <= grass_weight: #60:
		return grass_set[round((grass_set.size()-1)*variation_roll)]
	elif rock_set.size() > 0 && random_roll <= rock_weight+grass_weight:
		return rock_set[round((rock_set.size()-1)*variation_roll)]
	elif tree_set.size() > 0 && random_roll <= rock_weight+grass_weight+tree_weight:
		return tree_set[round((tree_set.size()-1)*variation_roll)]
	else:
		return empty_tile


func get_tile_info(coord : Vector2i, masks:Array =[])->Tile_Info:
	return pick_foliage(coord)
	
	
