class_name Player_Controlled_Brain extends Base_Brain

#NOTE: may keep the brain. allow disconnetion from character and controller
#only issue is if there more than one. could add a flag to disable it so the player
#handle can toggle it...though it may be best to assign or remove it
#could have the player handler create and assign it and have the character
#listen to actions from this.

func get_move_vector(pawn:Node2D = null) -> Vector2:
	##NOTE: this is a temp fix. need a better way to pause the player input
	if UI.enable_player_input:
		return Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
	else:
		return Vector2()
