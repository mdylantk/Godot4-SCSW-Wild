class_name Player_Controlled_Brain extends Base_Brain

#NOTE: may keep the brain. allow disconnetion from character and controller
#only issue is if there more than one. could add a flag to disable it so the player
#handle can toggle it...though it may be best to assign or remove it
#could have the player handler create and assign it and have the character
#listen to actions from this.
#TODO: due to being a resource, some functions are not avaible, so this may
#not be ideal for input. it be better in the player handler. this could handle signals
#and the player character can react to it. this would allow the brain to be known #
#to the player, but at the cost of the pawn being unkown. I rather keep the pawn
#ref and tell it where to move. the brain more for the pawn to make reaction to things
#that happening around it without hardcoding it into the character. AI may set a move
#to location to the brain, and then the pawn will use it to move in that direction
#just need to set up a logic path so it can let the brain modify direction if active
#(though may mess with input if not disabled)

func get_move_vector(pawn:Node2D = null) -> Vector2:
	##NOTE: this is a temp fix. need a better way to pause the player input
	if UI.enable_player_input:
		return Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
	else:
		return Vector2()
		
func get_direction(
		position:Vector2, velocity:Vector2=Vector2(),direction:Vector2=Vector2()
	)->Vector2:
	if UI.enable_player_input:
		return Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
	return Vector2()
