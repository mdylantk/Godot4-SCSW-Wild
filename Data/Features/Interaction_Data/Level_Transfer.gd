class_name Level_Transfer extends Interactive_Data

@export var level_data : Level_Data
@export var spawn_location : Vector2
@export var store_entry_point: bool = false
#if abover is true, then it need an id to save the location to(which is stated below)
@export var entry_point_id: String = "world"

func interact(handler, instigator, interactee, data):
	print_debug("MEOW")
	if level_data != null:	
		print_debug("meow loading level data")
		#NOTE: spawn location may not need to be pass if this will handle that logic
		#also the level day may not need to store the id. could use this perhaps?
		General_Events.change_level(level_data, handler, instigator, spawn_location) 
		if store_entry_point:
			var old_location : Vector2 = instigator.global_position
			handler.state.store(entry_point_id,old_location,"positions")
		var level_id = level_data.get_level_property("level_id")
		if level_id != null:
			#NOTE: assuming the handler have a state. AI handler might not? (but could and probably should)
			if handler.state != null and instigator != null:
				if handler.state.fetch(level_id, "positions") != null:
					var new_location = handler.state.fetch(level_id, "positions") + spawn_location
					instigator.global_position = new_location
		
	else:
		print_debug("no level data")
	super(handler, instigator, interactee, data)

	
