##this is to allow advance control of a character or node that support it.
class_name Brain extends Node

signal controller_assigned(new_controller:Controller)
signal controller_unassigned(old_controller:Controller)

#chaining controller signals that may also be called by the brain
signal action_triggered(action:String, value:Variant)



@export var controller:Controller :
	set(value):
		if controller != value:
			if controller != null:
				controller.action_triggered.disconnect(trigger_action)
				controller_unassigned.emit(controller)
			if value != null:
				value.action_triggered.connect(trigger_action)
				controller_assigned.emit(value)
			controller = value
	
func trigger_action(action:String, value:Variant):
	action_triggered.emit(action,value)

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
