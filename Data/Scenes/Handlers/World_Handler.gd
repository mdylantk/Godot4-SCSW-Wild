#@tool
class_name World_Handler extends Node2D

#TODO: add common world event as signals and call them correct so they can be listen to
#updates that state it pos/souce and if it load/unloaded
signal chunk_update(tile_map, chunk_position, is_unloaded)
#signal region_update

#TODO: maybe have a world state(or meta) to state what persetaint actor are in a region
#this could be link with a region
#(also if one tilemap per region works, then could slowly generate all the tiles after
#main ones are done). 

@export var tile_size : float = 16 #this is more dependent on the tile map, but the value should be fixed
@export var chunk_size : float = 32
#todo: load/save this value prbably in a world save. most seeds could be handle
#by the noise settings, but sometime a seed may need to be shared
@export var world_seed : int = 0

@export var level_data : Level_Data :
	set(value):
		print_debug("setting level")
		if level_data != value:
			if value != null:
				value.level_created.connect(on_level_created)
				value.level_removed.connect(on_level_removed)
				value.load_level()
				#if (level_data as Level_Data_2D) != null:
				#	value.loaded_point = loaded_point
				
			if level_data != null:
				level_data.unload_level()
				level_data.level_created.disconnect(on_level_created)
				level_data.level_removed.disconnect(on_level_removed)
				
			
			#print_debug("level set")
			level_data = value
#			clear_chunks(loaded_chunks.keys())
			#for old_pos in loaded_chunks.keys():
			#	chuck_update(old_pos,false)
			#	remove_child(loaded_chunks[old_pos])
			#	loaded_chunks[old_pos].queue_free()
			#	loaded_chunks.erase(old_pos)
#			generate_chunks()
#		level_data.seed_maps(world_seed)
	get:
		return level_data
		
func on_level_created(level:Node):
	#print_debug(level)
	add_child(level)
	#call_deferred("add_child",level)
	pass
func on_level_removed(level:Node):
	if level != self and level.get_parent() != null:
		remove_child(level)
	elif(level.get_parent() == null):
		print_debug("level parent is null")
	else:
		print_debug("someone trying to detached world handler from itself")
	#print_debug(level)
	#call_deferred("remove_child",level)
	#remove_child(level)
	pass
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
#		level_data.loaded_point = value
		#TODO: connect all the logic to level_data branch
		#or basicly disable most logic here and trigger it in level_data_2D
##		generate_chunks()
	get:
		return loaded_point
		
#NOTE: it also may be better to only have one loader and just load the map around them
#if other player are added, this could be a bit of an issue by adding teathering
#but also allow the map size to be predictable. 
#NOTE: to add a loader system, the old system would need to caculate more than one
#boundry which may be a bit to caculate and test(add/subtract squares). in short a
#array of coords would need to be caculated when processing loaders. then these
#are used as the points to load the chunks. also would need to unload chunks
#though a region system would simplify it to just unload a region of it too far
#from ant of the loaders. meaning the first array of locations are chunks that need to be loaded
#the the region and adj regions should slowly load
#var loaders : Array[Node2D] #using node2d instead of node since this use 2d coords
	#NOTE: this is to add a way to load chucks around an object. ideally to allow
	#path finding. usally it for the player, but could be used for importaint nearby
	#ai at the cost of loading more
	#TODO: make use of loaders and try to have this run on tick or update itself
	#when chunks are not loaded. could add regions as well and use an array
	#for chunks and the region could be an dict since only a few region should
	#be loaded
	
	
#preload only work with the direct path, not id
#var default_scene = preload("res://Data/Scenes/Maps/TilemapTemplate.tscn")
#var rare_scene = preload("res://Data/Scenes/Maps/RareTemplate.tscn")

var loaded_chunks = {}

func _ready():
	if world_seed == 0:
		world_seed = randi()
	if level_data != null:
		#level_data.level_created.connect(on_level_created)
		#level_data.level_removed.connect(on_level_removed)
		level_data.load_level()
		level_data.loaded_point = loaded_point
	#generate_chunks()

func change_level(new_level_data, instigator = null, location_offset = Vector2()):
	#test change via group call
	print_debug("changing level")
	level_data = new_level_data


func is_chunk_loaded(location,  load = true):
	#map size not needed since there a var that better above(chunk_distance).
	#var map_size = chunk_size * tile_size
#	if level_data != null:
#		return level_data.is_chunk_loaded(location,  false)
	return true
	pass
#	var grid_location = (location/chunk_distance).round()
#	if load:
#		load_chunks(location)
#	if loaded_chunks.has(grid_location):
#		return loaded_chunks[grid_location].visible
#	else:
#		return false


#TODO: should let the world watch out for players
#then send that info to the level_data to decided on how it should be used
var player_pawns :Array[Node] = []

#NOTE: could process one at a time or use the array when dealing with
#a timer
#TODO: player can signal to game to spawn pawn and remove. 
#then game can tell world to spawn pawn. world then spawn it base on logic
#in it self and the level_data. may need a default spawn position
#NOTE: could have the spawning also pass a location, but setting the pawn should do that
#so maybe just pass a bool stating if spawning postion is set or need to be set(meaning
#to state if the world should adjust pawn position)
#NOTE: could have a branch for pawn spawn only and then the world have a spawn
#player that will do that logic. could make func branches of owning and unowning pawns
#that just swaps the pawn in and put of the regeristry, but setting a player group is easier
#the unposseded can be a group call
func _process(delta):
	if level_data == null:
		return
	for pawn in player_pawns:
		if pawn == null:
			player_pawns.erase(pawn)
		elif pawn.is_in_group("player_controlled"):
			
			level_data.process_players(pawn)
			#TODO add some function to level data
			pass
		else:
			player_pawns.erase(pawn)

func _on_child_entered_tree(node):
	#print_debug(node)
	if node.is_in_group("player_controlled"): #and !player_pawns.has(node):
		print_debug(node)
		player_pawns.append(node)
		print_debug(player_pawns)


func _on_child_exiting_tree(node):
	#print_debug(node)
	if player_pawns.has(node):
		player_pawns.erase(node)
