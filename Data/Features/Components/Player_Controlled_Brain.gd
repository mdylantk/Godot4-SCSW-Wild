class_name Player_Controlled_Brain extends Base_Brain


#NOTE: currenly base brain has direction and returns it by default. This
#is here incase the controller uses the brain for action. ideally the pawn should be controlled
#directly instead of checking strings so actions may be reserve for simple brain ai

#func get_direction(
#		position:Vector2, velocity:Vector2=Vector2(),direction:Vector2=Vector2()
#	)->Vector2:
	#if Player.is_processing_unhandled_input():
	#	return Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
#	return _direction
