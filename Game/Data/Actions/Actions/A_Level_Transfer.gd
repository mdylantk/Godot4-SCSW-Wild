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


func run(data:Action_Data = null) -> bool:
	if level_uid != "":
		#var handler : Node = data["handler"]
		#var instigator : Node  = data["source"]
		#var new_location : = Vector2()
		if data == null:
			return false
		if data.owner as Node2D:
			
			if store_entry_point:
				var old_location : Vector2 = data.owner.global_position
				Savedata_Helper.store_player_position(Player,old_location,entry_point_id)
				#Player.state.store(entry_point_id,old_location,"positions")
		else:
			return false
		var level_loaded : Base_Level = World.load_level(level_uid, spawn_index) #should return bool to see if it ran
	return super(data)
