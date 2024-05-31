class_name Player_Controlled_Brain extends Base_Brain

func get_move_vector(current_position := Vector2()) -> Vector2:
	return Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
