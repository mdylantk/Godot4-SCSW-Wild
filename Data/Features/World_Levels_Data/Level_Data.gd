class_name Level_Data extends Resource

signal level_created(level:Node)
signal level_removed(level:Node)
signal entity_created(entity:Node)
signal entity_removed(entity:Node)

#an identifier used to link this level to other or similar levels
#the main use is to catch a position for this level so that players can
#swap back to that point when re-entering that level. also using a metadata or dict
#and grab data from dynamic getters and setters could be useful

#NOTE: TODO: need to make sure the instance spawn in a resonable place
#and that the player get sent to that point
#ideally the instance is center at 0,0 and world are base on a player
#var or a direct setting from the transfer

#Note: this is an abstract getter so levels can add expose 
#public properties instead of delaring it here
func get_level_property(name:String) -> Variant:
	return null

func is_level_loaded(location:Vector2)->bool:
	return true
	

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

