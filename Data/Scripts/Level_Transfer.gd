class_name Level_Transfer extends Interactive_Data

@export var level_data : Level_Data_2D

func interact(_instigator,_owner,_data = null):
	#if _instigator is Player_Handler:
		#brainstorming passing handler as a ref
		#but may not be needed here, but where the world transfer takes place
		#so transfer may need to be move to game handler maybe
		#or this may need to comunicate more directly to world handler
		#(issue is this functionality is known by player and direct call will make it known by world/game
		#which would know about player. not sure if any of theses are indirect ref so it be best to try to add one
		#NOTE: may not need this. it all depends on what change_level needs
	#	pass
	#else:
	if level_data != null:
		#pass
		print_debug("loading level data")
		_instigator.get_tree().call_group("World_Handler", "change_level", level_data,_instigator)
	else:
		print_debug("no level data")
		#_instigator.get_tree().call_group("World_Handler", "change_level", level_data,_instigator)
	super(_instigator,_owner,_data)

	
