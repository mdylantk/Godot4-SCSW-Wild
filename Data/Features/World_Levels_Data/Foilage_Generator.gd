class_name Foilage_Generator extends Generator_Data

@export var region_size : int = Region_Data.region_size
@export var chunk_size : int = Region_Data.chunk_size

@export var detail_map : Noise = FastNoiseLite.new()
@export var variation_map : Noise = FastNoiseLite.new()

@export var grass_tiles : Array[Vector2i] = [Vector2i(5,0),Vector2i(6,0),
	Vector2i(7,0),Vector2i(0,2),Vector2i(0,0)]
@export var tree_tiles : Array[Vector2i] = [Vector2i(0,1),Vector2i(1,1),
	Vector2i(2,1),Vector2i(3,1),Vector2i(4,1),Vector2i(5,1),Vector2i(3,2),
	Vector2i(4,2),Vector2i(6,2),Vector2i(0,0)]
@export var rock_tiles : Array[Vector2i] = [Vector2i(5,2),Vector2i(1,0),
	Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(0,0)]


func generate(tilemap:Node):
	if (tilemap as TileMap) != null:
		await generate_tilemap(tilemap)
	if tilemap != null:
		scene_finished.emit(self,tilemap)
	else:
		print_debug("WARNING: tilemap is null")

func generate_with_data(data: Array):
	
	data_finished.emit(self,data)


func pick_foliage_tile(pos):
	
	var variation_roll = (variation_map.get_noise_2d(pos.x,pos.y)+1)/2
	var random_roll = (detail_map.get_noise_2d(pos.x,pos.y)+1)*50
	
	if grass_tiles.size() > 0 && random_roll >= 50: #60:
		return grass_tiles[round((grass_tiles.size()-1)*variation_roll)]
	elif rock_tiles.size() > 0 && random_roll < 10:
		return rock_tiles[round((rock_tiles.size()-1)*variation_roll)]
	elif tree_tiles.size() > 0 && random_roll < 45:
		return tree_tiles[round((tree_tiles.size()-1)*variation_roll)]
	else:
		return Vector2i(0, 0)
		
func tile_picker(
		tilemap:TileMap,region_coords:Vector2i, chunk_coords:Vector2i,
		data:Array = [], use_data:bool = false
	):
	var coords = Vector2i(chunk_coords+(region_coords*chunk_size))
	var tile = pick_foliage_tile(coords)
	if use_data:
		if coords.x >= data.size():
			data.append([])
		if coords.y >= data[coords.x].size():
			data.append([])
		data[coords.x][coords.y] = tile

	else:
		tilemap.set_cell(0,coords,0,tile)

func generate_tilemap(
		tilemap:TileMap, data:Array = [], use_data:bool = false
	):
	for region_x in range(region_size):
		for region_y in range(region_size):
			if self != null and tilemap != null:
				for chunk_x in range(chunk_size):
					for chunk_y in range(chunk_size):
						tile_picker(tilemap,Vector2i(region_x,region_y),
						Vector2i(chunk_x,chunk_y), data, use_data)
			else:
				return
			await Game.get_tree().create_timer(0.05).timeout
#NOTE: the one thar calls this needs to know when it is ready
#	loaded_tilemaps[coords] = tilemap
#	processing_tilemaps.erase(coords)
