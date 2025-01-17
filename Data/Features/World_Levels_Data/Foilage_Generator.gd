class_name Foilage_Generator extends Generator_Data

@export var region_size : int = 8
@export var chunk_size : int = 8

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
	#NOTE: old, trying to switch to tilemap layer
	if (tilemap as TileMap) != null:
		await generate_tilemap(tilemap)
	elif (tilemap as TileMapLayer) != null:
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
		tilemap:TileMapLayer,region_coords:Vector2i, chunk_coords:Vector2i,
		data:Array = [], use_data:bool = false
	):
	var coords = Vector2i(chunk_coords+(region_coords*chunk_size))
	var tile = pick_foliage_tile(coords)
	if use_data:
		if coords.x >= data.size():
			data.append([])
		if coords.y >= data[coords.x].size():
			data.append([])
		if data[coords.x][coords.y] == null:
			data[coords.x][coords.y] = tile
		else:
			print_debug("tile not null, passing")

	else:
		#NOTE: currently only generate on null zones of the first 4 layers
		#this means foilage wont generate on place ground. 
		#TODO: decide if the tiles should be update on all layers or 
		#should put into the data and render later. the lag not really
		#noticable and may be easier like this. could add objects
		#for deciding how each layer is picked.
		#instead of running multple generators, could have a generator that run
		#steps together
		if (
				tilemap.get_cell_tile_data(coords) == null# &&
				#tilemap.get_cell_tile_data(coords) == null #&&
				#tilemap.get_cell_tile_data(2,coords) == null 
			):
			#TODO in the future there may be proper ground
			#the idea is to have a layer for ground and surface ground
			#then a layer for objects
			#base ground could be check if null or all of the zones could be
			#in general if land and air tiles are used, then layer 0 should have some data
			#NOTE: seem with the current system, full land added around 30 mb of ram
			#NOTE: also with a collsion for full land, that an additonal ~50 mb (~80)
			#NOTE: with a nav layer, the amount is increase by another ~60mb (~140mb)
			#BIG NOTE: Can not have nav on 0,0 (the empty tile) else the fps tanks. collsion is fine
			#this is the ground layer 
			
			#tilemap.set_cell(1,coords,0,Vector2(17,0))
			#this is the foilage
			tilemap.set_cell(coords,0,tile)
		#NOTE: land and see can not be in the same tile. it may be best
		#to either deisgn it to be land and water with both collsions or
		#not have land as collsion and manually check if not water for enities
		#that can only swim
		#NOTE: also could use land layer on water edge to fake it. the issue then
		#is the water need the ends else it will let enities pass
		#if (tilemap.get_cell_tile_data(0,coords) == null):
		#	tilemap.set_cell(0,coords,2,Vector2(2,1))

#Note: this might not be uses since there is no levels. may need to bundle layers at
#most. should just handle each layer with diffrent generators. currtly using one layer
#but the upper level would need to keep track of maps in layers
func format_tilemap_layers(tilemap:TileMap):
	#the ground level
	tilemap.set_layer_z_index(0,0)
	tilemap.set_layer_y_sort_enabled(0,true)
	#the object level
	if tilemap.get_layers_count() < 2:
		tilemap.add_layer(1)
		tilemap.set_layer_y_sort_enabled(1,true)
		tilemap. set_layer_z_index(1,0)
	#the overhead level
	#if tilemap.get_layers_count() < 3:
	#	tilemap.add_layer(2)
	#	tilemap.set_layer_y_sort_enabled(2,true)
	#	tilemap. set_layer_z_index(2,2)
	#NOTE: could set tile meta (like one for type or flags) so it can check the type 
	#instead of seeing if it null. water_foilable can allow water table foilage and land
	#for land(but currently it be null since there is no land). 
	#TODO: decide on single or multi layers. multi may be useful if switch to
	#a more detail tilesets

func generate_tilemap(
		tilemap:TileMapLayer, data:Array = [], use_data:bool = false
	):
	#format_tilemap_layers(tilemap)
	for region_x in range(region_size):
		for region_y in range(region_size):
			if self != null and tilemap != null:
				for chunk_x in range(chunk_size):
					for chunk_y in range(chunk_size):
						tile_picker(tilemap,Vector2i(region_x,region_y),
						Vector2i(chunk_x,chunk_y), data, use_data)
			else:
				return 
			await Game.get_tree().process_frame
			#await Game.get_tree().create_timer(0.05).timeout
#NOTE: the one thar calls this needs to know when it is ready
#	loaded_tilemaps[coords] = tilemap
#	processing_tilemaps.erase(coords)
