class_name A_Level_Transfer extends Base_Action

@export var level_data : Level_Data
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
	if level_data != null:
		var handler : Node = data["handler"]
		var instigator : Node  = data["source"]
		#NOTE: spawn location may not need to be pass if this will handle that logic
		#also the level day may not need to store the id. could use this perhaps?
		General_Events.change_level(level_data, handler, instigator, spawn_location) 
		if store_entry_point:
			var old_location : Vector2 = instigator.global_position
			Savedata_Helper.store_player_position(handler,old_location,entry_point_id)
#			handler.state.store(entry_point_id,old_location,"positions")

		var new_location = level_data.get_spawn_position(spawn_index, handler)
		var level_id = level_data.get_level_property("level_id")
		if level_id != null:
			#NOTE: assuming the handler have a state. AI handler might not? (but could and probably should)
			new_location = Savedata_Helper.fetch_player_position(handler,level_id)
		instigator.global_position = new_location #NOTE: need a way to check if it vaild
#			if handler.state != null and instigator != null:
#				if handler.state.fetch(level_id, "positions") != null:
#					var new_location = handler.state.fetch(level_id, "positions") + spawn_location
#					instigator.global_position = new_location
		
	else:
		print_debug("no level data")
