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
			Savedata_Helper.store_player_position(handler,old_location,entry_point_id)
		
		var level_loaded : Base_Level = World.load_level(level_uid, spawn_index) #should return bool to see if it ran
