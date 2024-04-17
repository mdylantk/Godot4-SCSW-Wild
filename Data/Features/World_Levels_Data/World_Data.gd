class_name World_Data extends Level_Data

##An identifier for use when saving data like last position.
@export var level_id := "world"

@export var use_game_seed: bool = true

#TODO: make it so it will use all the generator instead of [0]
#this would require data passs/return instead of setting directly
##Tile generator to run on nonstatic tilemaps.
@export var generators : Array[Generator_Data]

#TODO: rename static maps to World_name(x,y) or region_name(x,y) and store them
#in a folder representing the world. or map(x,y) works too. only issue is that
#the coords means nothing. they are just for organiztion reason. also if using region_name
#the cords will represent the chunk pos within the region, not world. still only useful
#for orgaition. wouild be nice to load in regions, but that will over complex the system
#better to have a tooling system where regions can be edited and the maps in the region
#get exported to the world_Data. there local position down scale to grib pos off set by
#the region position located in the map world.

#TODO add a region size/bound option to allow generation upto a certain size

##Scenes to load at region positions. 
##Entries should be Vector2:Object where Object should be a PackedScene
@export var static_chunks : Dictionary

##Scenes that will spawn randomly in the world.
@export var random_chunks : Array[PackedScene]

##A noise to represent where the scenes will spawn.
##Noise should have decent range of grays and should be noisy else they will spawn in clusters.
@export var random_chunk_noise_map : FastNoiseLite = FastNoiseLite.new()

##The Tileset to use for nonstatic tilemaps
@export var tile_set : TileSet = preload("res://Data/Assets/low_Bit_Tileset.tres")

func update_static_regions():
	for key in static_chunks:
		if typeof(key) != TYPE_VECTOR2 or !(static_chunks[key] is PackedScene):
			print_debug("Warning, static_chunks should be Vector2:PackScene")
	return



var tile_size : float = 16 #this is more dependent on the tile map, but the value should be fixed
var chunk_size : float = 8
var region_size : float = 8
var chunk_distance : float = tile_size*chunk_size*region_size

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


var _deferring_handle_tilemaps := false

var near_by_coords :Array[Vector2i] =[
		Vector2(-1,-1),Vector2(-1,0), Vector2(-1, 1),
		Vector2(0,0),Vector2(0,-1), Vector2(1, -1),
		Vector2(1,1),Vector2(0,1), Vector2(1,0)
	]
	
#@export var grass_tiles : Array[Vector2i] = [Vector2i(5,0),Vector2i(6,0),
#	Vector2i(7,0),Vector2i(0,2),Vector2i(0,0)]
#@export var tree_tiles : Array[Vector2i] = [Vector2i(0,1),Vector2i(1,1),
#	Vector2i(2,1),Vector2i(3,1),Vector2i(4,1),Vector2i(5,1),Vector2i(3,2),
#	Vector2i(4,2),Vector2i(6,2),Vector2i(0,0)]
#@export var rock_tiles : Array[Vector2i] = [Vector2i(5,2),Vector2i(1,0),
#	Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(0,0)]

#TODO: So far added a way to handle and load tilemap to replace the old system
#just need to move the generation logic over here

func get_level_property(name:String) -> Variant:
	if name == "level_id":
		return level_id
	return null


#temp fixes
func load_static_tilemap(static_map:Node,coords:Vector2i):
	static_tilemaps[coords] = static_map
	static_map.transform[2] = level_coords_to_world(coords)
	var processing_map = static_map as One_Bit_Tilemap
	level_created.emit(static_map)
	await Game.get_tree().create_timer(1).timeout
	loaded_tilemaps[coords] = static_map
	#loaded_tilemaps[coords] = static_map
	#TODO add a way to check to see if tilemap is loaded
	#could force add the foilage generator to it
	#and ignore other generators
#temp fixes end

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
	var coords := world_to_level_coords(location) as Vector2
	#TODO: may need to convert the static chunks as vector2i instead of vector2
	if static_chunks.has(coords):
		return static_chunks[coords].instantiate()
	elif random_chunks.size() > 0:
		#currently a 40% chance? to spawn an instance
		#but the chance really depends on the noise map contrast. need lots of 
		#various grays. random noise too, not blobs
		var noise_value = random_chunk_noise_map.get_noise_2d(coords.x,coords.y)
		noise_value += 1
		noise_value *= random_chunks.size()/2
		var min =floor(noise_value)
		var max =ceil(noise_value)
		var portion = noise_value - min
		if portion <= 0.2:
			return random_chunks[min].instantiate()
		elif portion >= 0.8:
			return random_chunks[max].instantiate()
	#TODO: need to see if a random static chunk is picked
	return null

func is_tilemap_ready(coords:Vector2i) -> bool:
	if processing_tilemaps.has(coords):
		return false
	else:
		if static_tilemaps.has(coords):
			#NOTE: this is to allow static map to handle themselves
			var tilemap : Node = loaded_tilemaps[coords]
			if tilemap.has_meta("is_ready"):
				return tilemap.get_meta("is_ready", false)
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
	_deferring_handle_tilemaps = false

func caculate_active_regions(position:Vector2):
	var loader_coords = world_to_level_coords(position)
	for coord in near_by_coords:
		var grid_position = loader_coords + coord
		if !active_regions.has(grid_position):
			active_regions.append(grid_position)
		if !_deferring_handle_tilemaps:
			call_deferred("handle_tilemaps")
			_deferring_handle_tilemaps = true


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

func load_level():
	if !generators[0].scene_finished.is_connected(on_generator_end):
		generators[0].scene_finished.connect(on_generator_end)

func unload_level():
	clear_tilemaps(loaded_tilemaps)
	clear_tilemaps(processing_tilemaps)
	clear_tilemaps(loose_tilemaps)
	clear_tilemaps(static_tilemaps)
	
	_deferring_handle_tilemaps = false
	active_regions = []
	#clear_chunks(loaded_chunks.keys())
	pass

func process_players(pawn:Node):
	if pawn as Node2D:
		var grid_location = world_to_level_coords(pawn.global_position)
		#loaded_point = grid_location
		caculate_active_regions(pawn.global_position)

#WORLD Handler old logic

func is_level_loaded(location:Vector2)->bool:
	var coords = world_to_level_coords(location)
	return loaded_tilemaps.has(coords)
	#return loaded_tilemaps.has(coords) or loose_tilemaps.has(coords)
	
