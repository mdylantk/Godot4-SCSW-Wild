class_name Movement_Component_2D extends Resource

#TODO: Maybe have a dedicated movement state (refcounted?) that
#the component uses for advances cases. it will hold the lastest collsion
#data and extra (dynamic) properties. that would allow this to be more than 
#a veclodity caculator and manage the pass state. NOTE: this is fine as long
#as there are dedicated characters. dedicated movement componets are for cases
#where one character is used by functions varies base on the componets used

@export var base_speed : float = 64

##this is how much sprint will modify the speed
##The exact way would be what is declare in get_speed() or other functions.
@export var sprint_modifier : float = 1

##This is the sprint flag, but it is a float incase it needs to be handle as
##an input strength
var sprint_strength : float = 0

func calculate_velocity(
		velocity:Vector2, 
		direction:Vector2 = Vector2.ZERO,
		last_collision:KinematicCollision2D = null
	)->Vector2:
	var new_velocity:Vector2 = velocity
	if direction != Vector2.ZERO:
		new_velocity = (direction*get_speed())
	else:
		new_velocity = Vector2.ZERO
	return new_velocity
	
func get_speed():
	return (sprint_modifier*sprint_strength+1)*base_speed
