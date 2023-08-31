class_name Level_Transfer extends Interactive_Data

@export var level_data : Level_Data_2D

func interact(_instigator,_owner,_data = null):
	
	if level_data != null:
		#pass
		print_debug("loading level data")
		_instigator.get_tree().call_group("World_Handler", "change_level", level_data,_instigator)
	else:
		print_debug("no level data")
		#_instigator.get_tree().call_group("World_Handler", "change_level", level_data,_instigator)
	
	super(_instigator,_owner,_data)
	pass
	
