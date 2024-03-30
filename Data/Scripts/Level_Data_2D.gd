class_name Level_Data_2D extends Level_Data

@export_file("*.tscn") var default_chunk : String = "res://Data/Scenes/Maps/TilemapTemplate.tscn"
#@export var null_chunk : PackedScene
@export_file("*.tscn") var null_chunk : String = "res://Data/Scenes/Maps/NullZone.tscn"
@export var return_null_on_default: bool = false 


#may use this instead of return_null_on_default
#will generate default or random tiles up to bounds unless ignored. 
@export var level_max_bounds: Vector2
@export var level_min_bounds: Vector2
@export var use_level_bounds: bool = false
@export var use_game_seed: bool = true

#Noise should be related to level which basicly world data
#also should decide how to seed them. could base it on world seed +- an offset
#or have it fixed and have the seed editable. if world noise map, could use a save object, just need to
#seed it game start.
@export var generators : Array[Generator_Data]
@export var tempture_map : Noise
@export var humidity_map : Noise
#detail is ment to be for if a feature spawn or it empty space/unchanged. 
@export var detail_map : Noise
#variation is for picking the variation of a tile.
@export var variation_map : Noise
@export var height_map : Noise = FastNoiseLite.new()
#note: a way to handle random chunks are still needed. currently usong array[0] inless 10% chance
#is rolled...then a random array between 0-max is picked

#should be ref by id and loaded in via regions else if small then just need an object to get the data from
#@export var old_static_chunks : Dictionary = { 
	#Vector2(0,0):"uid://blyxjt47otoln", 
	#Vector2(4,8):"uid://clicnkneu0ddm",
	#Vector2(7,-2):"uid://bngicde5fixcp",
	#Vector2(-4,5):"uid://cyg3wosoq0787",
	#Vector2(-9,-6):"uid://t7rhh625brgr",
	#Vector2(-3,0):"uid://duqgklvehxux0",
	#Vector2(0,11):"uid://bbaafkh4f04vx",
	#Vector2(0,-21):"uid://t7rhh625brgr",
	#Vector2(42,0):"uid://clicnkneu0ddm"
	#}
	
@export var chunks : Array[Chunk_Data] :
	set(value):
		chunks = value
		#sort_chunks()
	get:
		return chunks

#TODO add a region size/bound option to allow generation upto a certain size

var static_chunks = {}
var random_chunks = []


@export var tile_set : TileSet = preload("res://Data/Assets/low_Bit_Tileset.tres")

var tile_size : float = 16 #this is more dependent on the tile map, but the value should be fixed
var chunk_size : float = Region_Data.chunk_size
var region_size : float = Region_Data.chunk_size*Region_Data.region_size
var chunk_distance : float = tile_size*(region_size)

#currently loaded maps
var loaded_tilemaps := {}
#maps that are flaged out of range
var loose_tilemaps := {}
var max_loose_maps : int = 8
#static maps that can not be recycled
#currently not in use, but may be the opposite of processing. also tilemaps
#that are static will have additonal data. either a scene or an object with data and genration logic
var static_tilemaps := {}
#maps that are loaded, but not ready
var processing_tilemaps := {}
var processing : bool = false
#a array of catch positions. any tilemap not equal any will be move to loosed
var active_regions : Array[Vector2i]

var deferring_handle_tilemaps := false

var near_by_coords :Array[Vector2i] =[
		Vector2(-1,-1),Vector2(-1,0), Vector2(-1, 1),
		Vector2(0,0),Vector2(0,-1), Vector2(1, -1),
		Vector2(1,1),Vector2(0,1), Vector2(1,0)
	]
	
@export var grass_tiles : Array[Vector2i] = [Vector2i(5,0),Vector2i(6,0),
	Vector2i(7,0),Vector2i(0,2),Vector2i(0,0)]
@export var tree_tiles : Array[Vector2i] = [Vector2i(0,1),Vector2i(1,1),
	Vector2i(2,1),Vector2i(3,1),Vector2i(4,1),Vector2i(5,1),Vector2i(3,2),
	Vector2i(4,2),Vector2i(6,2),Vector2i(0,0)]
@export var rock_tiles : Array[Vector2i] = [Vector2i(5,2),Vector2i(1,0),
	Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(0,0)]

#TODO: So far added a way to handle and load tilemap to replace the old system
#just need to move the generation logic over here

###ONE BIT TILEMAP GENERATION CODE PEICES
func pick_foliage_tile(pos):
	var noise_value = round((height_map.get_noise_2d(pos.x,pos.y)+1)*5)
	var water_value = round(height_map.get_noise_2d(pos.x,pos.y))
	var variation_roll = randf()
	var random_roll = randi() % 100
	if detail_map != null and variation_map != null:
		#NOTE: detail_map is the statement if there an object or not as well as pick the upper type
		random_roll = (detail_map.get_noise_2d(pos.x*5,pos.y*5)+1)*50
		#NOTE: variation_map is to decide what to pick form an array
		variation_roll = (variation_map.get_noise_2d(pos.x*5,pos.y*5)+1)/2
	
	if water_value < 0:
		return Vector2i(8,5)
	elif grass_tiles.size() > 0 && random_roll >= 50: #60:
		return grass_tiles[round((grass_tiles.size()-1)*variation_roll)]
	elif rock_tiles.size() > 0 && random_roll < 10:
		return rock_tiles[round((rock_tiles.size()-1)*variation_roll)]
	elif tree_tiles.size() > 0 && random_roll < 45:
		return tree_tiles[round((tree_tiles.size()-1)*variation_roll)]
	else:
		return Vector2i(0, 0)

##ONE BIT TILEMAP CODE END

##temp fixes
func load_static_tilemap(static_map:Node,coords:Vector2i):
	static_tilemaps[coords] = static_map
	level_created.emit(static_map)
	static_map.transform[2] = level_coords_to_world(coords)
	await Game.get_tree().create_timer(1).timeout
	loaded_tilemaps[coords] = static_map
##temp fixes end

func clear_tilemaps(tilemap_dictionary:Dictionary):
	for coords in tilemap_dictionary.keys():
		var tilemap = tilemap_dictionary[coords]
		if tilemap != null :
			level_removed.emit(tilemap)
			tilemap.queue_free()
		else:
			print_debug("WARNING: tilemap is null")
		tilemap_dictionary.erase(coords)
	

func get_static_map(location:Vector2)->Node:
	for chunk in chunks:
		if chunk.is_static_chunk:
			if chunk.static_location == location:
				return load(chunk.chunk_scene_path).instantiate()
	return null

func tile_picker(tilemap:TileMap,coords:Vector2i):
	var tile = pick_foliage_tile(coords)
	#tilemap.call_deferred("set_cell",0,coords,0,tile)
	tilemap.set_cell(0,coords,0,tile)

func generate_tilemap(tilemap:TileMap, coords:Vector2i):
	for region_x in range(Region_Data.region_size):
		for region_y in range(Region_Data.region_size):
			if self != null and tilemap != null:
				for chunk_x in range(Region_Data.chunk_size):
					for chunk_y in range(Region_Data.chunk_size):
						tile_picker(tilemap,Vector2i(
							chunk_x + region_x * Region_Data.chunk_size,
							chunk_y + region_y * Region_Data.chunk_size
						))
			await Game.get_tree().process_frame
	loaded_tilemaps[coords] = tilemap
	processing_tilemaps.erase(coords)

func is_tilemap_ready(coords:Vector2i) -> bool:
	if processing_tilemaps.has(coords):
		return false
	else:
		#if return false, tilemap dose not exist
		return dose_tilemap_exist(coords)

func dose_tilemap_exist(coords:Vector2i)-> bool:
	return (loaded_tilemaps.has(coords) or loose_tilemaps.has(coords)
		or processing_tilemaps.has(coords) or static_tilemaps.has(coords)
	)
	

func on_generator_end(generator:Generator_Data, scene:Node):
	var tilemap = (scene as TileMap)
	if tilemap != null:
		var coords = world_to_level_coords(tilemap.global_position)
		if processing_tilemaps.has(coords):
			loaded_tilemaps[coords] = tilemap
			processing_tilemaps.erase(coords)
	else:
		print_debug("WARNING: processing_tilemaps may have a null pointer")
		print("but also if that the case, this object may be null " + str(self))
	#generator.scene_finished.disconnect(on_generator_end)

func handle_tilemaps():
	#the timer is a placeholder. defer may be enough, so the update rate is all that may need to be handle
	#await Game.get_tree().create_timer(1.0).timeout
	for coords in active_regions:
		if loose_tilemaps.has(coords):
			#print_debug("flagging importaint" + str(coords) )
			loaded_tilemaps[coords] = loose_tilemaps[coords]
			loose_tilemaps.erase(coords)
		elif !dose_tilemap_exist(coords):
			#print_debug("flagging new" + str(coords) )
			var static_map = get_static_map(level_coords_to_world(coords))
			if static_map != null:
				load_static_tilemap(static_map,coords)
				#loaded_tilemaps[coords] = static_map
				#static_tilemaps[coords] = static_map
				#level_created.emit(static_map)
				#static_map.transform[2] = level_coords_to_world(coords)
			else:
				var new_tilemap = create_tilemap()
				init_tilemap(new_tilemap,level_coords_to_world(coords))
				processing_tilemaps[coords] = new_tilemap
				
				#generate_tilemap(new_tilemap, coords)
				#print("Meoow " + str(coords))
				generators[0].generate(new_tilemap)

	for loaded_coords in loaded_tilemaps.keys():
		var loaded_map = loaded_tilemaps[loaded_coords]
		if !active_regions.has(loaded_coords):
			#print_debug("flagging old" + str(loaded_coords))
			loose_tilemaps[loaded_coords] = loaded_tilemaps[loaded_coords]
			loaded_tilemaps.erase(loaded_coords)
	
	for loose_coords in loose_tilemaps.keys():
		var loose_map = loose_tilemaps[loose_coords]
		#remove
		if loose_tilemaps.size()>max_loose_maps:
			#print_debug("removing" + str(loose_coords) )
			if loose_map != null :
				level_removed.emit(loose_map)
				loose_map.queue_free()
			else:
				print_debug("WARNING: tilemap is null")
			if static_tilemaps.has(loose_coords):
				static_tilemaps.erase(loose_coords)
			loose_tilemaps.erase(loose_coords)
			if loose_tilemaps.size()<=max_loose_maps:
				break
	active_regions.clear()
	deferring_handle_tilemaps = false

func caculate_active_regions(position:Vector2):
	var loader_coords = world_to_level_coords(position)
	for coord in near_by_coords:
		var grid_position = loader_coords + coord
		if !active_regions.has(grid_position):
			active_regions.append(grid_position)
		if !deferring_handle_tilemaps:
			call_deferred("handle_tilemaps")
			deferring_handle_tilemaps = true


func create_tilemap():
	var tilemap := TileMap.new()
	level_created.emit(tilemap)
	return tilemap

#NOTE: need to load and init tilemap. this just set things up
func init_tilemap(tilemap:TileMap,coords:Vector2):
	#loaded_tilemaps[location] = tilemap
	tilemap.y_sort_enabled = true
	tilemap.texture_filter =CanvasItem.TEXTURE_FILTER_NEAREST
	tilemap.set_layer_y_sort_enabled(0,true)
	tilemap.transform[2] = coords
	if tilemap.tile_set == null: #NOTE: may want to force the tile_set? random maps should not need diffrent type
		tilemap.tile_set = tile_set

#var grid_position = Vector2(x,y) + offset + loaded_point
func world_to_level_coords(position: Vector2) -> Vector2i :
	return (position/chunk_distance).floor()
	#return Vector2i(position.x, position.y)
func level_coords_to_world(coords: Vector2i) -> Vector2 :
	return coords * chunk_distance
	#return Vector2i(coords.x, coords.y)

#func get_level_scene(position:Vector2):
#	return get_chunk(position)
	#return null
	
func load_level():
	if !generators[0].scene_finished.is_connected(on_generator_end):
		generators[0].scene_finished.connect(on_generator_end)

func unload_level():
	clear_tilemaps(loaded_tilemaps)
	clear_tilemaps(processing_tilemaps)
	clear_tilemaps(loose_tilemaps)
	clear_tilemaps(static_tilemaps)
	
	deferring_handle_tilemaps = false
	active_regions = []
	#clear_chunks(loaded_chunks.keys())
	pass

func process_players(pawn:Node):
	if pawn as Node2D:
		var grid_location = world_to_level_coords(pawn.global_position)
		#loaded_point = grid_location
		caculate_active_regions(pawn.global_position)



###WORLD Handler old logic###

var world_seed : int = 0


func is_level_loaded(location:Vector2)->bool:
	var coords = world_to_level_coords(location)
	return loaded_tilemaps.has(coords)
	#return loaded_tilemaps.has(coords) or loose_tilemaps.has(coords)
	
	
###world old logic END###





func _init():
	randomize_zero_seed(tempture_map)
	randomize_zero_seed(humidity_map)
	randomize_zero_seed(detail_map)
	randomize_zero_seed(variation_map)

func randomize_zero_seed(noise: Noise):
	if (noise != null):
		if noise.seed == 0:
			noise.seed = randi()

func seed_maps(new_seed : int):
	if use_game_seed :
		if (tempture_map != null):
			tempture_map.seed = new_seed
		if (humidity_map != null):
			humidity_map.seed = new_seed
		if (detail_map != null):
			detail_map.seed = new_seed
		if (variation_map != null):
			variation_map.seed = new_seed

