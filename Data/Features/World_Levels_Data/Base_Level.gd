class_name Base_Level extends Node

#this may replace world data
#enities are usally contrain to a level and not the world
#controllers would have to decide what can be transfer over. 
#if viewports are understood better, then this may make it easier to transfer
#the reason to switch from resource from node is the level can be design better
#and additional logic can be add (not hard coded) above the map at the cost of
#some node limitation due to its abstraction.

#TODO decide if the it should be a node or node2d or another class

#NOTE will remate level_data here to try to reused world and instance data
#TODO: should create level under itself same with enities
signal level_created(level:Node)
signal level_removed(level:Node)
signal entity_created(entity:Node)
signal entity_removed(entity:Node)

#this may or maynot be used. could be use as a node
@export var environment_data : Environment_Data

@export var default_spawn_position : Vector2
@export var use_default_spawn_position : bool = false


func get_level_property(name:StringName) -> Variant:
	return null

func is_level_loaded(location:Vector2)->bool:
	return true

#either use a string or an int for the spawn location id
#int is less readable, smaller, and probably quicker
#but both cases require looking in the level data to know what is avalible
#but default is return if not used. could also plug in an enum to level transfer
#and aggree to reserve the index for the enum amount and anything else is extra
#handler is pass incase it need a stored position
func get_spawn_position(spawn_index:int=0, handler:Node = null)->Vector2:
	if use_default_spawn_position:
		return default_spawn_position
	return Vector2()

#the main functions to start and end the level_data
func load_level():
	pass
func unload_level():
	pass

#a function getting level ref at the region position. children should override this
#since the logic may need to be diffrent, it may just return an empty region data
#or it will return a tilemap scene wither from a dic or just one. it should return a scene
#since region is just a helper object and state for generation or chunk/region base logic

func get_level_scene(position:Vector2) -> Node:
	return null
	pass

#TODO this should be handle directly by detecting entry/leaving of node tree and group id
func process_players(pawn:Node):
	pass
