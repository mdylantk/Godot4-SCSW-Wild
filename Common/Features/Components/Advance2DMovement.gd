class_name Advance2DMovement extends Movement_Component_2D

@export var acceleration : float = 256
@export var deacceleration : float = 256
var acceleration_velocity : Vector2
##this is a test to try out gravity and platforming
@export var is_platformer : bool = false
##a way to test gravity values

@export var max_jumps : int = 2
var jumps : int = 0

func calculate_velocity(
		direction:Vector2 = Vector2.ZERO,
		body:CharacterBody2D = null,
		delta:float = 1.0
	)->Vector2:
	var new_velocity:Vector2 = body.velocity
	var new_direction:Vector2 = direction
	if is_platformer:
		#limit movement to the x axis
		new_velocity = Vector2(body.velocity.x,0.0)
		new_direction = Vector2(direction.x,0.0)
	#var speed:float = get_speed()
	var forces_velocity:Vector2 = calculate_forces_velocity(body,delta)

	if new_direction != Vector2.ZERO:
		new_velocity = new_velocity.move_toward(
			new_direction*get_max_speed(),acceleration*(sprint_modifier*sprint_strength+1)*delta
		)
		new_velocity += forces_velocity
	else:
		new_velocity = new_velocity.move_toward(
			Vector2.ZERO,deacceleration*delta
		)
		new_velocity += forces_velocity
	return new_velocity

#NOTE TODO:
#may be using move to incorrectly and  the delta is really the decrease power (and delta is aplready applied_
func apply_forces(
	body:CharacterBody2D = null,
	delta:float=1.0
)->void:
	super(body,delta)
	if body.is_on_floor() and jumps > 0:
		jumps = 0

func gravity_enable()->bool:
	return is_platformer

func can_jump(body:CharacterBody2D = null,up_direction = Vector2.UP) -> bool:
	if !gravity_enable():
		return false
	if body:
		if !body.is_on_floor() and jumps >= max_jumps:
			return false
	return true

func jump(
	body:CharacterBody2D = null,
	up_direction:Vector2 = Vector2.UP
)->bool:
	if (!super(body,up_direction)):
		return false 
	jumps += 1
	return true
