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

#TODO: to allow moblie player to play, the game need to handle touch input
#easy way is to add a UI that acts like the buttons, but also can so touch and move
#and use a simple AI navigator to decide on the action. could add buttons or add a 
#double tap feature that would do the default action (or hold to bring up a list)
#or have move to trigger the default action if distance too short. may be better
#to use an UI and add a touch button for settings so the UI can be displayed
#though the move to point would be a nice thing to test to see how it handle switching
#from direct and indirect
