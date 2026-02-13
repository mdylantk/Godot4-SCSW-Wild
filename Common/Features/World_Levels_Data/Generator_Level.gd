class_name Generator_Level extends Base_Level

@export var level_id := "world"

@export var player_state : Player_State = Player_State.get_default_instance()
@export var game_state : Game_State = Game_State.get_default_instance()
@export var world_state : World_State = World_State.get_default_instance()

@export var light_color_curve : Gradient = load('uid://cnotvdiw4vtvo')
#@export var use_game_seed: bool = true

#TODO: make it so it will use all the generator instead of [0]
#this would require data passs/return instead of setting directly
#Tile generator to run on nonstatic tilemaps.
#@export var generators : Array[Generator_Data]

#TODO: should try to use scenes so a default scene is used with the desired
#format. 

##Scenes to load at region positions. 
##Entries should be Vector2:String where String should be a scene uid or path
@export var static_chunks : Dictionary

##Scenes that will spawn randomly in the world. Should be scene uid or path.
@export var random_chunks : Array[String]
#@export_file("*.tscn") var instance_scene : String = "uid://hepasgr3svoi"

##A noise to represent where the scenes will spawn.
##Noise should have decent range of grays and should be noisy else they will spawn in clusters.
@export var random_chunk_noise_map : FastNoiseLite = FastNoiseLite.new()

#The Tileset to use for nonstatic tilemaps
#@export var tile_set : TileSet = preload("res://Data/Assets/low_Bit_Tileset.tres")

@export var default_chunk : PackedScene = preload("uid://ba1djs75axgrn")

var tile_size : float = 16 #this is more dependent on the tile map, but the value should be fixed
var chunk_size : float = 8
var region_size : float = 8
var chunk_distance : float = tile_size*chunk_size*region_size

#currently loaded maps
var loaded_regions := {}
#maps that are flaged out of range
var loose_regions := {}
var max_loose_regions : int = 8
#static maps that can not be recycled
#currently not in use, but may be the opposite of processing. also tilemaps
#that are static will have additonal data. either a scene or an object with data and genration logic
var static_regions := {}
#maps that are loaded, but not ready
#var processing_regions := {}
#var processing : bool = false
#a array of catch positions. any tilemap not equal any will be move to loosed
var active_regions : Array[Vector2i]


var _deferring_handle_regions := false

var near_by_coords :Array[Vector2i] =[
		Vector2(-1,-1),Vector2(-1,0), Vector2(-1, 1),
		Vector2(0,0),Vector2(0,-1), Vector2(1, -1),
		Vector2(1,1),Vector2(0,1), Vector2(1,0)
	]

##States if the regions around the viewport is fully loaded or not
var is_ready:bool = true

func update_static_regions():
	for key in static_chunks:
		if typeof(key) != TYPE_VECTOR2 or !(static_chunks[key] is PackedScene):
			print_debug("Warning, static_chunks should be Vector2:PackScene")
	return

#NOTE: check if this is still being used. ideally the new system this handle 
#the player location instead of some parent.
func get_level_property(name:StringName) -> Variant:
	if name == "level_id":
		return level_id
	return null
	
	
func world_to_level_coords(position: Vector2) -> Vector2i :
	return (position/chunk_distance).floor()
	
func level_coords_to_world(coords: Vector2i) -> Vector2 :
	return coords * chunk_distance

func load_default_region(coords:Vector2i):
	var tilemap : Node = default_chunk.instantiate()
	tilemap.transform[2] = level_coords_to_world(coords)
	add_child(tilemap)
	loaded_regions[coords] = tilemap


func load_static_region(static_map:Node,coords:Vector2i):
	static_regions[coords] = static_map
	static_map.transform[2] = level_coords_to_world(coords)
	add_child(static_map)
	#await Game.get_tree().create_timer(1).timeout
	loaded_regions[coords] = static_map
	

func clear_tilemaps(tilemap_dictionary:Dictionary):
	for coords in tilemap_dictionary.keys():
		var tilemap = tilemap_dictionary[coords]
		if tilemap != null :
#			map_removed(tilemap)
			#level_removed.emit(tilemap)
			tilemap.call_deferred("queue_free")
		else:
			print_debug("WARNING: tilemap is null")
		tilemap_dictionary.erase(coords)
	

func get_static_map(location:Vector2)->Node:
	var coords := world_to_level_coords(location) as Vector2
	#TODO: may need to convert the static chunks as vector2i instead of vector2
	if static_chunks.has(coords):
		if static_chunks[coords] != null:
			return load(static_chunks[coords]).instantiate()
		else:
			print(static_chunks[coords])
	elif random_chunks.size() > 0:
		#currently a 40% chance? to spawn an instance
		#but the chance really depends on the noise map contrast. need lots of 
		#various grays. random noise too, not blobs
		var noise_value = random_chunk_noise_map.get_noise_2d(coords.x,coords.y)
		noise_value += 1
		noise_value *= float(random_chunks.size())/2
		var min_index = floor(noise_value)
		var max_index = ceil(noise_value)
		var portion = noise_value - min_index
		if portion <= 0.2:
			return load(random_chunks[min_index]).instantiate()
		elif portion >= 0.8:
			return load(random_chunks[max_index]).instantiate()
	#TODO: need to see if a random static chunk is picked
	return null

func is_region_ready(coords:Vector2i) -> bool:
	if loaded_regions.has(coords):
		var region : Tilemap_Handler = loaded_regions[coords] as Tilemap_Handler
		if region:
			return region.is_ready
	if static_regions.has(coords):
		var region : Node = static_regions[coords]
		if (region as Tilemap_Handler):
			return region.is_ready
		else:
			return region.get_meta("is_ready",false) 
		return dose_region_exist(coords)
	return false

func dose_region_exist(coords:Vector2i)-> bool:
	return (loaded_regions.has(coords) or loose_regions.has(coords)
		or static_regions.has(coords)
	)


func handle_regions():
	for coords in active_regions:
		if loose_regions.has(coords):
			loaded_regions[coords] = loose_regions[coords]
			loose_regions.erase(coords)
		elif !dose_region_exist(coords):
			var static_map = get_static_map(level_coords_to_world(coords))
			if static_map != null:
				load_static_region(static_map,coords)
			else:
				load_default_region(coords)


	for loaded_coords in loaded_regions.keys():
		var loaded_map = loaded_regions[loaded_coords]
		if !active_regions.has(loaded_coords):
			loose_regions[loaded_coords] = loaded_regions[loaded_coords]
			loaded_regions.erase(loaded_coords)
	
	for loose_coords in loose_regions.keys():
		var loose_map = loose_regions[loose_coords]
		if loose_regions.size()>max_loose_regions:
			if loose_map != null :
				loose_map.call_deferred("queue_free")
			else:
				print_debug("WARNING: tilemap is null")
			if static_regions.has(loose_coords):
				static_regions.erase(loose_coords)
			loose_regions.erase(loose_coords)
			if loose_regions.size()<=max_loose_regions:
				break
	active_regions.clear()
	_deferring_handle_regions = false

func caculate_active_regions(world_coord:Vector2):
	var loader_coords = world_to_level_coords(world_coord)
	for coord in near_by_coords:
		var grid_position = loader_coords + coord
		if !active_regions.has(grid_position):
			active_regions.append(grid_position)
		
		#first call will not be ready, but after it will depend on the
		#Regions loaded
		is_ready = !is_region_ready(world_to_level_coords(world_coord+Vector2(coord)))
			
	if !_deferring_handle_regions:
		call_deferred("handle_regions")
		_deferring_handle_regions = true


func _process(delta: float) -> void:
	
	caculate_active_regions(get_viewport().get_camera_2d().global_position)
	world_state.is_level_loading = is_ready
	#var time : float = fmod(game_state.game_time,100.0)
	var time : float = fmod(game_state.game_time/game_state.time_in_day,1.0)
	%CanvasModulate.color = light_color_curve.sample(time)
	

func _ready() -> void:
	var player_pos : Vector2 = %Player.position
	match world_state.transfer_type :
		0:
			pass
		1:
			if (player_state.has_vector('pawn_position')):
				%Player.global_position = player_state.get_vector('pawn_position',2,false)
			if (player_state.has_vector('pawn_facing')):
				%Player.facing_direction = player_state.get_vector('pawn_facing',2,false)
		2:
			if player_state.exit_data.override_entry_position:
				%Player.global_position = (
					player_state.exit_data.entry_position +
					player_state.exit_data.entry_offset
				)
			%Player.facing_direction = player_state.exit_data.facing_direction
			%Player.velocity = player_state.exit_data.entry_velocity
			#may need to let the transfer action handles this and pull
			#from exit data. may need to make two transfers to reduce clutter
			#the world transfer use the id while new uses the override position
			#or keep as one and override position is for local chuck(be confusing though)
			#if (player_state.has_vector('world_location')):
			#	%Player.global_position = player_state.get_vector('world_location',2,false)
	#	player_pos = player_state.positions['world_location'] 
	#var player_pos = Savedata_Helper.fetch_player_position(Player,"world")
	#%Player.position = player_pos
