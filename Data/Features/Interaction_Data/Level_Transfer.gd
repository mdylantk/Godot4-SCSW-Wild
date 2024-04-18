class_name Level_Transfer extends Interactive_Data

@export var level_data : Level_Data
@export var spawn_location : Vector2
@export var store_entry_point: bool = false
#if abover is true, then it need an id to save the location to(which is stated below)
#NOTE: may need a way to clear up the data if unused, but it be best to override types to only use a few
#design wise, this can break if one do not reset the stored points when overring spawn position
#ALSO may need to rethink this system. it may be a bit confusing to understand since the
#entry_point_id is the would the player is in, but this handles the new level. it works, but 
#a bit odd
@export var entry_point_id: String = "world"

func interact(handler, instigator, interactee, data):
	if level_data != null:
		#NOTE: spawn location may not need to be pass if this will handle that logic
		#also the level day may not need to store the id. could use this perhaps?
		General_Events.change_level(level_data, handler, instigator, spawn_location) 
		if store_entry_point:
			var old_location : Vector2 = instigator.global_position
			Savedata_Helper.store_player_position(handler,old_location,entry_point_id)
#			handler.state.store(entry_point_id,old_location,"positions")
		var level_id = level_data.get_level_property("level_id")
		if level_id != null:
			#NOTE: assuming the handler have a state. AI handler might not? (but could and probably should)
			var new_location = Savedata_Helper.fetch_player_position(handler,level_id)
			instigator.global_position = new_location #NOTE: need a way to check if it vaild
#			if handler.state != null and instigator != null:
#				if handler.state.fetch(level_id, "positions") != null:
#					var new_location = handler.state.fetch(level_id, "positions") + spawn_location
#					instigator.global_position = new_location
		
	else:
		print_debug("no level data")
	super(handler, instigator, interactee, data)

	
