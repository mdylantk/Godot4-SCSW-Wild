#TODO: rename this world or chunk level or something and remove from autoload
#and then create a new world handler that just store infor about the world state
#and share data for all level
#this also means that the game would need to handle level change diffrently
#since the new world handler would not have acess to that ability ( or
#it could with signals)
#NOTE:TODO: can change the function to call a signal and have the level
#listen to it. this would allow the logic to split without breaking everything
#but the solution would be temporary. tne chunk handler should probably handle loading itself

class_name World_Handler extends Node

#NOTE: the new level loading/unloading should use the godot current scene feature
#there is a delay, so the logic flow would be broken up at when it want to change
#changing, and when the level is loaded in the scene tree (a frame after this happen usally)
#can also listen to the scene tree for changes, but only in the game handler since
#this should not know what gose on outside of itself
signal level_changed(new_level : Base_Level, spawn_index : int)
signal level_changing(uid:String)
signal world_update()
signal level_ready()
signal level_busy()
#below are temp signals meant to help with the detachement
signal request_level_load(uid:String, spawn_index : int)
signal request_unload_level(level:Base_Level)

#TODO: add common world event as signals and call them correct so they can be listen to
#updates that state it pos/souce and if it load/unloaded
#signal chunk_update(tile_map, chunk_position, is_unloaded)
#signal region_update

@export var tile_size : float = 16 #this is more dependent on the tile map, but the value should be fixed
@export var world_seed : int = 0

@export var max_levels_stored : int = 2

@export var world_enviroment : Environment_Data

## a flag the level can set to true if it not ready after its ready function
var level_loading : bool = false :
	set(value):
		if value != level_loading:
			level_loading = value
			if level_loading:
				level_busy.emit()
			else:
				level_ready.emit()

var loaded_levels := {}
#this just store the current level. only one per client unless viewport is used to solve
#the issue of being ine the same World2d
var loaded_level : Base_Level
func load_level(uid:String, spawn_index : int = 0) -> Base_Level:
	level_busy.emit()
	level_changing.emit(uid)
	level_changed.emit(get_tree().current_scene, spawn_index)
	#NOTE: current scene most likly will be null. would need to await
	#or something. returning a scene really not nessary. 
	return get_tree().current_scene
	
	print_debug("meow")
	if !loaded_levels.has(uid):
		var new_level = (load(uid) as PackedScene).instantiate()
		if new_level != null:
			loaded_levels[uid] = new_level
			add_child(new_level)
			unload_level(loaded_level)
			loaded_level = new_level
	else:
		add_child(loaded_levels[uid])
		unload_level(loaded_level)
		loaded_level = loaded_levels[uid]
	if loaded_level != null: #just a check, but usally should not happen unless
		#loaded_level.load_level()
		if loaded_level.environment_data == null:
			%CanvasModulate.color = Color(1,1,1,1)
	else:
		%CanvasModulate.color = Color(1,1,1,1)
	level_changed.emit(loaded_level, spawn_index)
	remove_unused_levels()
	return loaded_level

		
#will unload from scene, but not remove from memory
func unload_level(level:Base_Level):
	if loaded_level != null:
		remove_child(loaded_level)
		
func remove_unused_levels():
	for level_uid in loaded_levels.keys():
		var level : Base_Level = loaded_levels[level_uid]
		if level == loaded_level:
			level.active_age = 1
		elif level.active_age >= max_levels_stored:
			#level.unload_level()
			loaded_levels.erase(level_uid)
			level.call_deferred("queue_free")
		else:
			level.active_age += 1

var is_time_setting: bool = false
	
func _ready():
	print_debug("I am ready")
	if world_seed == 0:
		world_seed = randi()


#TODO: change name to: is_loaded_at or is_ready_at unless chunk end up sounding better
func is_chunk_loaded(location):
	if loaded_level != null:
		return loaded_level.is_level_loaded(location)
	return true


#NOTE: can get world location from HUD, but getting it here may be a bit odd
#also if server, kind of need to know about the player so this may be idea
func _on_child_entered_tree(node):
	pass
	#print_debug(node)
	#if node.is_in_group("player_controlled"): #and !player_pawns.has(node):
	#	player_pawns.append(node)



func _on_child_exiting_tree(node):
	#print_debug(node)
	pass
	#if player_pawns.has(node):
	#	player_pawns.erase(node)

#todo: need to change this new system require level to change the evioment directly
#NOTE: modulate here overriding the one in world, so turing it off for now
func _on_world_clock_timeout() -> void:
	world_enviroment.forward_time()
