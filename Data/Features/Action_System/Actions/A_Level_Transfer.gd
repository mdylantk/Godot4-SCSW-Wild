class_name A_Level_Transfer extends Base_Action

@export var level_uid : String
@export var spawn_location : Vector2 #not going to be used? can modify the player var if needed
@export var store_entry_point: bool = false
@export var entry_point_id:StringName = "world"
@export var spawn_index : int = 0

#NOTE: need a better way to handle player position
#could split the action. one to store position, then level switch(this logic), and
#then relocate player. also could have this store and relocate, but need a way to handle
#relocate. either by id or fix value. could have it use an action or just keep the action seprated

#also could add entry points to level data or just have level data handles where the 
#player spawns. also may need to let the handler knows there a levels switch, but
#the world probably should handle that


func run(data:={}):
	if level_uid != "":
		var handler : Node = data["handler"]
		var instigator : Node  = data["source"]
		var new_location : = Vector2()
		#NOTE: spawn location may not need to be pass if this will handle that logic
		#also the level day may not need to store the id. could use this perhaps?
		if store_entry_point:
			var old_location : Vector2 = instigator.global_position
			#TODO: should not use savedata helper (maybe?) i mean it can help with
			#mass renaming. the point is to store a list of points that can be reloaded
			#exit data can state the area id and exit id that can be used to look up 
			#the point if the point is not static (aka random generated zone on world map
			#the map wont know the points except the entrances. this can be saved as an location
			#so the player can return to that point in the world)
			Savedata_Helper.store_player_position(handler,old_location,entry_point_id)
			
		#NOTE TODO since new system will focus on client/authorty level switching
		#the unit that triggers this would be player 0 controlled (aka the player
		#Player represent). if another player triggers this, it would be a server side evet
		#that this trigged on their side. can just handle that in a transfer level logic
		#TODO: temp exit infomation probably should be given to the world so other
		#levels can look it up. this not ment to be saved. it for deciding on placement
		#when loading in. things like facing direction, entry id, and even entry velocity
		
		#NOTE: there no dedicated player handler, so a handler need to be pass
		#to acess it. it be best to make one and then manage other players states
		#that way, but most likly the network side will process it and the players be more
		#like an ai controller driven by network updates
		#NOTE: could also use group instead of directly acessing player handler
		#this would allow the pawn to be set or relocated
		var level_loaded : Base_Level = World.load_level(level_uid, spawn_index) #should return bool to see if it ran
