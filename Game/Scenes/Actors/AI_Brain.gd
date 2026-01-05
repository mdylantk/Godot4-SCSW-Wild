class_name AI_Brain extends Brain


@export var move_to_location : Vector2
@export var desire_distance : float = 16
##this will return the pass direction or use the direction in caculations
##if false, it will return (0,0) in cases where the logic fails
@export var preserve_direction : bool = true

@export var debug_location : Vector2

var at_target_location : bool = false


func get_move_to_location() -> Vector2:
	#TODO: decide on if an object should be used or keep it abstract with dict
	#just need a share way to store info so pawns can act diffrently
	var move_to
	if controller:
		if controller.has_meta(&"move_to"):
			move_to = controller.get_meta(&"move_to")
			if typeof(move_to) == TYPE_VECTOR2:
				return move_to
			if typeof(move_to) == TYPE_OBJECT:
				if is_instance_valid(move_to):
					if (move_to as Node2D) != null:
						return move_to.global_position
	return move_to_location

	
func get_direction(
		position:Vector2, velocity:Vector2=Vector2()
	)->Vector2:
	var direction : Vector2
	if controller:
		direction = controller.direction
	
	at_target_location = (position - get_move_to_location()).length() < desire_distance
	if at_target_location: #test to see if it stop at the target
		if preserve_direction:
			return direction
		return Vector2() #direr
	var move_to = get_move_to_location()
	#will use the move to location if there is no metadata
	return Vector2(position.direction_to(move_to))
	
	
	
	return direction



#NOTE this is the func that gets called. 
func get_move_direction(position:Vector2, velocity:Vector2=Vector2()) -> Vector2:
	debug_location = get_direction(position,velocity)
	return get_direction(position,velocity)
