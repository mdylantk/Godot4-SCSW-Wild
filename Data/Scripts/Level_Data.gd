class_name Level_Data extends Resource

signal level_created(level:Node)
signal level_removed(level:Node)
signal entity_created(entity:Node)
signal entity_removed(entity:Node)

#NOTE: this is more of a hard offset for non-world levels
#instances will use this to spawn the level at the tiggering player
#position. still need to tp the player pawn to the correct spot most if the time
#also can be used by exits indirectlt. exit gives offset base on 0,0 instead of storing this
var world_position : Vector2 :
	set(value):
		if !world_position_change(value,world_position):
			world_position = value

#NOTE: this class is meant to be the base class of level data
#for use to handle populating generated worlds, loading static worlds,
#as well as any others. bulk logic will be in the children

###NOTE: this should handle most if not all the level logic
#world just add and remove nodes as well as load and unload levels


#this is overriddable incase something need to change
func world_position_change(new_position:Vector2, old_position:Vector2) -> bool :
	#returns true means it override the set logic
	return false
	

#NOTE: maybe level_data should listen to player and not use calls
#then levels that do not care wont need to monitor the player
#func player_position_update(position:Vector2, player:Player_Handler):
#	pass
	


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
#once the level is pulled(if any) its data should be return for processing
#the world will handle loading and unloading the level, but new levels may
#need addition logic done and this is what this is for. (Note: it might be awaitable)
#logic be like generating foilage or full generation. unit spawning would be
#either tilemap base or another handler base. This could handle that, 
#but for now that logic can be reserve for later
#the issue is that this should not call to the world(except for signals) but
#the world can freely talk to this.

###NOTE:this handles the logic of the data or act as the middle man between
#level scene and world handler. it also should contain data for connecting
#levels. the world handler role is loading, unloading, and redirection of levels
#and enitites. world may also hold points like active world position, though they
#may work better here, but switching level_data may make thing difficult without a buffer
#in the world handler
#NOTE level scene may handle itself but should only in cases where it do not need
#to know about other regions(or have a soild signal system for that) 
func process_scene_instance(scene:Node,position:Vector2):
	pass
