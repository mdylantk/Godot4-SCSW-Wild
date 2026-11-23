##this handles independent AI cacucations for character/pawns
class_name Brain extends Node

signal controller_assigned(new_controller:Controller)
signal controller_unassigned(old_controller:Controller)


@export var controller:Controller :
	set(value):
		if controller != value:
			if controller != null:
				controller_unassign(controller)
				controller_unassigned.emit(controller)
			if value != null:
				controller_assign(value)
				controller_assigned.emit(value)
			controller = value

##this is where the controller connections will be assign
func controller_assign(new_controller:Controller)->void:
	pass
	
##this is where the controller connections will be disconnected
func controller_unassign(old_controller:Controller)->void:
	pass
	
##run the logic for caculating the desired direction to move
##can be used to move between points, walk in a circle, or other things
func get_move_direction(position:Vector2, velocity:Vector2=Vector2()) -> Vector2:
	if controller:
		return controller.direction
	return Vector2()

##some actions are togglable and this is where one could look them up
func get_action_state(action:String, default_state:Variant = 0)->Variant:
	if controller:
		return controller.action_states.get(action)
	return default_state
