class_name Player_Controlled_Brain extends Base_Brain

func get_move_vector(pawn:Node2D = null) -> Vector2:
	return Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
