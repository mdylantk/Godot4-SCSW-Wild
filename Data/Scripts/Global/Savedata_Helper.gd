class_name Savedata_Helper extends Object
#this is to help get/set common save values so it easier to debug or update
#only issue is changing names would break saves. A converter could be made
#to try to patch it, but it best to try not to change the structure after
#a save system is fully added.

#TODO: start moving the logic here. logic like inventory may be abstract?
#by requiring a dictionary or object for the item stack(NOTE: dicts may be easier to save than objects
#unless object is built to be conveted to a savable type)

#Structure is get/set with a varible of some type. if the save source dynamic
#then that source need to be pass. example anything with a player_handler
#could probably get the player, but better to have it passed here
#NOTE: generic save of data is fine. can help keep this small.

#TODO: make a controller handler for AI and player handlers to inherit from
#NOTE: inventory and enity states may need to be save on the enitity else 
#stored on the handler. later is better so the handlers can spawn it
#the handler could be the world, but may be better for the controller handlers
#to do the storing so the world only need to worry about level_data stuff
#NOTE: in the above case, this class probably should not be used
#but may call a static save lib that handle loading/saving files or the handler
#call such libary

#mostly for world position. should not be used for all locations, just ones that
#contain dynamic entrances like random poi on the world map. 
static func store_player_position(handler:Player_Handler,new_location:Vector2,id:String):
	handler.state.store(id,new_location,"positions")
	
static func fetch_player_position(handler:Player_Handler,id:String)->Vector2:
	var value = handler.state.fetch(id,"positions")
	if typeof(value) == TYPE_VECTOR2:
		return value
	else:
		return Vector2()

#Generic score set/get by an id. using a int since most score are counters
static func store_player_score(handler:Player_Handler,new_score:int,id:String):
	handler.state.store(id,new_score,"scores")
	
static func fetch_player_score(handler:Player_Handler,id:String)->int:
	var value = handler.state.fetch(id,"scores")
	if typeof(value) == TYPE_INT:
		return value
	else:
		return 0
	
