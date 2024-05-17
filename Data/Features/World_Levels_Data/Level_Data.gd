class_name Level_Data extends Resource

signal level_created(level:Node)
signal level_removed(level:Node)
signal entity_created(entity:Node)
signal entity_removed(entity:Node)

@export var environment_data : Environment_Data


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

func process_players(pawn:Node):
	pass
