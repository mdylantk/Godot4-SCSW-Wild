class_name World_Handler extends Node

signal level_changed(new_level : Base_Level, spawn_index : int)

#TODO: add common world event as signals and call them correct so they can be listen to
#updates that state it pos/souce and if it load/unloaded
#signal chunk_update(tile_map, chunk_position, is_unloaded)
#signal region_update

@export var tile_size : float = 16 #this is more dependent on the tile map, but the value should be fixed
@export var world_seed : int = 0

@export var max_levels_stored : int = 2

var loaded_levels := {}
#this just store the current level. only one per client unless viewport is used to solve
#the issue of being ine the same World2d
var loaded_level : Base_Level
func load_level(uid:String, spawn_index : int = 0) -> Base_Level:
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


func _on_world_clock_timeout() -> void:
	if loaded_level != null: 
		if loaded_level .environment_data == null:
			return
		var enviroment:Environment_Data = loaded_level.environment_data
		enviroment.forward_time()
		%CanvasModulate.color = enviroment.get_environment_color()
