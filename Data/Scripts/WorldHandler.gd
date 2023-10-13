@tool
class_name World_Handler extends Node2D

#TODO: add common world event as signals and call them correct so they can be listen to
#updates that state it pos/souce and if it load/unloaded
signal chunk_update(tile_map, chunk_position, is_unloaded)
#signal region_update

static var world_handler : World_Handler

#TODO: maybe have a world state(or meta) to state what persetaint actor are in a region
#this could be link with a region
#(also if one tilemap per region works, then could slowly generate all the tiles after
#main ones are done). 

@export var tile_size : float = 16 #this is more dependent on the tile map, but the value should be fixed
@export var chunk_size : float = 32

@export var level_data : Level_Data_2D :
	set(value):
		print_debug("setting level")
		if level_data != value:
			#print_debug("level set")
			level_data = value
			clear_chunks(loaded_chunks.keys())
			#for old_pos in loaded_chunks.keys():
			#	chuck_update(old_pos,false)
			#	remove_child(loaded_chunks[old_pos])
			#	loaded_chunks[old_pos].queue_free()
			#	loaded_chunks.erase(old_pos)
			generate_chunks()
	get:
		return level_data
#TODO: maybe just have one handler for world, and how it load is determin by a resource
#stating static chunks and if it generate void chunks or not
#@export var static_chunks : Dictionary = { 
#	Vector2(0,0):"uid://blyxjt47otoln", 
#	Vector2(4,8):"uid://clicnkneu0ddm",
#	Vector2(7,-2):"uid://bngicde5fixcp",
#	Vector2(-4,5):"uid://cyg3wosoq0787",
#	Vector2(-9,-6):"uid://t7rhh625brgr",
#	Vector2(-3,0):"uid://duqgklvehxux0",
#	Vector2(0,11):"uid://bbaafkh4f04vx",
#	Vector2(0,-21):"uid://t7rhh625brgr",
#	Vector2(42,0):"uid://clicnkneu0ddm"
#	}
var chunk_distance = tile_size*(chunk_size+1)
var offset = Vector2(-2,-2)
@export var loaded_point = Vector2(0,0):
	set(value):
		loaded_point = value
		generate_chunks()
	get:
		return loaded_point
#preload only work with the direct path, not id
#var default_scene = preload("res://Data/Scenes/Maps/TilemapTemplate.tscn")
#var rare_scene = preload("res://Data/Scenes/Maps/RareTemplate.tscn")

var loaded_chunks = {}

func _ready():
	world_handler = self
	generate_chunks()

func change_level(new_level_data, instigator = null, location_offset = Vector2()):
	#test change via group call
	print_debug("changing level")
	level_data = new_level_data

func load_chunks(pos):
	var current_origin = loaded_point * chunk_distance
	if (pos.x >= current_origin.x + chunk_distance ||
		pos.x <= current_origin.x - chunk_distance ||
		pos.y >= current_origin.y + chunk_distance ||
		pos.y <= current_origin.y - chunk_distance ) :
			loaded_point = (pos/chunk_distance).round()
			#generate_chunks()

#func _process(_delta):
	#pass

func generate_chunks() :
	#var chunk_distance = tile_size*(chunk_size+1)
	var old_chunk_coord = loaded_chunks.keys()
	var x = 0
	var y = 0
	while x <= 3:
		while y <= 3:
			var grid_position = Vector2(x,y) + offset + loaded_point
			if !loaded_chunks.has(grid_position):
				var map
				if level_data != null:
					var chunk_ref = level_data.get_chunk(grid_position)
					if chunk_ref != null:
						#print("loading: " + str(chunk_ref))
						call_deferred("load_chunk",chunk_ref,grid_position,!chunk_ref is String)
			else:
				old_chunk_coord.remove_at(old_chunk_coord.find(grid_position))
			y += 1
		y = 0
		x += 1
	clear_chunks(old_chunk_coord)
	#for null_pos in old_chunk_coord:
	#	chuck_update(null_pos,false)
	#	remove_child(loaded_chunks[null_pos])
	#	loaded_chunks[null_pos].queue_free()
		#print_debug("removing")
		#print(str(null_pos))
		#print(loaded_chunks[null_pos])
	#	loaded_chunks.erase(null_pos)

func clear_chunks(old_chunk_coords : Array ):
	for null_pos in old_chunk_coords:
		
		chunk_update.emit(loaded_chunks[null_pos], null_pos, true) #map may be null
		
		chuck_update(null_pos,false)
		remove_child(loaded_chunks[null_pos])
		loaded_chunks[null_pos].queue_free()
		loaded_chunks.erase(null_pos)

func load_chunk(ref,location = Vector2(), is_loaded = true) :
	var map
	if loaded_chunks.has(location):
		#print_debug("warning location exist, ignoring loading chunk")
		return
	if is_loaded :
		map = ref.instantiate()
	else:
		var loaded_ref = load(ref)
		map = loaded_ref.instantiate()
	map.transform[2] = chunk_distance * location
	add_child(map)
	loaded_chunks[location] = map
	#map.connect("on_chunk_ready", chuck_ready)
	if map.has_signal("on_chunk_ready"): #tool cause errors here so map may not be fully ready? 
		map.on_chunk_ready.connect(chuck_update)
		
	#todo, decide on a better location. this call it when a new map is spawn(since currently each map a chunk)
	chunk_update.emit(map, location, false)

func get_current_chunk(location):
	var chunk_pos = (location/chunk_distance).round()
	#print(chunk_pos)
	if loaded_chunks.has(chunk_pos):
		return loaded_chunks[chunk_pos]
	#elif preloaded_chunks.has(chunk_pos):
	#	return preloaded_chunks[chunk_pos]
	else:
		return null
		

func chuck_update(pos,is_ready = true):
	#need to decide on pos or chunk pos. the signal use pos, but unload use chunk
	#the issues is where map size is located(currently here) so children do not know about it
	var map_size = chunk_size * tile_size
	if is_ready:
		get_tree().call_group("Player_Handlers", "chunk_update", (pos/map_size).round(), map_size, is_ready)
	else:
		get_tree().call_group("Player_Handlers", "chunk_update", pos, map_size, is_ready)
