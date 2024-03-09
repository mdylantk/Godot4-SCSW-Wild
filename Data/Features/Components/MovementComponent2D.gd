class_name Movement_Component_2D extends Resource
#this hold share functionality between moving an object
#as well as common varibles. It will not move the object
#but provide the caculation needed to move as desired
@export var base_speed : float = 64
@export var facing_dirction : Vector2 = Vector2.RIGHT
@export var sprint_modifier : float = 1

var sprint_strength : float = 0

#TODO desice on the desired function this should share and any
#variable that should always be needed
func update_velocity(velocity:Vector2, direction:Vector2 = Vector2.ZERO):
	var new_velocity:Vector2 = velocity
	if direction != Vector2.ZERO:
		facing_dirction = direction
		new_velocity = (direction*get_speed())
	else:
		new_velocity = Vector2.ZERO
	#this will apply forces to velocity
	#such as acceration and breaking
	return new_velocity
	
func get_speed():
	#may need to clamp sprint_strength
	return (sprint_modifier*sprint_strength+1)*base_speed
