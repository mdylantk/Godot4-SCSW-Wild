class_name Player_Controlled_Brain extends Base_Brain

func get_move_vector(pawn:Node2D = null) -> Vector2:
	##NOTE: this is a temp fix. need a better way to pause the player input
	if UI.enable_player_input:
		return Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
	else:
		return Vector2()
