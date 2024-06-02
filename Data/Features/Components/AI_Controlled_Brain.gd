class_name AI_Controlled_Brain extends Base_Brain


#NOTE could use update for more advance versions to change focus location
#can swap it out is nessary. just need signals to notify changes in the state
#TODO: this should handle more than movement. things like when to do an action or 
#not to do it. could also do that in update and send signals to notify owner
#of a change. like stating an attack is desired. AI controller could class check
#so it only will try to listen of brain is a vaild AI brain (so the base AI brain
#should know the signals used. if it cant, then an abstract signal should be used
#or another class check


@export var move_to_location : Vector2
@export var desire_distance : float = 16
var at_target_location : bool = false

func get_move_vector(pawn:Node2D = null) -> Vector2:
	if at_target_location: #test to see if it stop at the target
		return Vector2()
	var move_to = get_move_to_location()
	#will use the move to location if there is no metadata
	return Vector2(pawn.global_position.direction_to(move_to))

func get_move_to_location() -> Vector2:
	if has_meta(&"move_to"):
		var move_to = get_meta(&"move_to")
		if typeof(move_to) == TYPE_VECTOR2:
			return move_to
		if (move_to as Node2D) != null:
			return move_to.global_position
	return move_to_location

#an example case for func update(): is to see if target is near current location
#may need to pass location) and if true, change location to a new one. 
func update(pawn:Node2D = null, handler: Controller_Handler = null) -> void :
	at_target_location = (pawn.global_position - get_move_to_location()).length() < desire_distance
	pass
