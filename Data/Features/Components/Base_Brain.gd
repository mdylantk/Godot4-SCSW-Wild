class_name Base_Brain extends Resource
##ask for the controller/character(or listerner) that it would like to do an action.
##This action usally an input event triggers like attack or interact
signal character_action_request(id:StringName)

#NOTE: decided to use the controller (and it state) for the share data. update
#roll is to store data locally to be used for other function(if needed) else
#could pass handlers to thouse function if nessary

#TODO need to pass a direction, velocity, and possibly a medtadta/object
#and let the brain return something from that. get_Direction will return a direction
#either the one passed or a modified one
##This allows the brain to override the direction.
##should be called before the move logic
func get_direction(
		position:Vector2, velocity:Vector2=Vector2(),direction:Vector2=Vector2()
	)->Vector2:
	return Vector2() 

##old get direction logic
##things like pawns should be passes elsewhere and is unquie to the child
func get_move_vector(pawn:Node2D = null) -> Vector2:
	return Vector2()

#should be called from a timer or owning node. it ment to run checks to deicide actions
#so it should not need to run often. usally when a change is made or to similate reaction time of AI
##This may not be needed. parent or handler should set stuff here and it should update
##as needed. 
func update(pawn:Node2D = null, handler: Controller_Handler = null) -> void :
	#print_debug("meowing " + str(pawn))
	pass
