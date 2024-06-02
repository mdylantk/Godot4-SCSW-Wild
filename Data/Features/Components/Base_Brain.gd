class_name Base_Brain extends Resource
##ask for the controller/character(or listerner) that it would like to do an action.
##This action usally an input event triggers like attack or interact
signal character_action_request(id:StringName)

#NOTE: decided to use the controller (and it state) for the share data. update
#roll is to store data locally to be used for other function(if needed) else
#could pass handlers to thouse function if nessary

func get_move_vector(pawn:Node2D = null) -> Vector2:
	return Vector2()

#should be called from a timer or owning node. it ment to run checks to deicide actions
#so it should not need to run often. usally when a change is made or to similate reaction time of AI
func update(pawn:Node2D = null, handler: Controller_Handler = null) -> void :
	#print_debug("meowing " + str(pawn))
	pass
