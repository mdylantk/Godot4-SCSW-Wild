#TODO: moving most of this to the world state and manage by the game handler
#or maybe all. 
#NOTE: world time currently updating an evioment object
#but could use a global shader and expose the timeout/time to
#the world state. a level evioment could update on process
#if it dynamic though. it is only one thing and should not cost much
#could also listen to the world clock update, but not sure if it be better
#to update time in the game process(issue is if pausing causes issues, then
#the timer be better)
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

@export var state : World_State = load('uid://b047ftosxvj7p')

## a flag the level can set to true if it not ready after its ready function

func get_level_id()->String:
	if get_tree().current_scene:
		return get_tree().current_scene.name
	return String()


var is_time_setting: bool = false
	
func _ready():
	#state.load_level.connect(load_level)
	print_debug("I am ready")
	if world_seed == 0:
		world_seed = randi()


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
