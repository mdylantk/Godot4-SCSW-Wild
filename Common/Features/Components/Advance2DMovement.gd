class_name Advance2DMovement extends Movement_Component_2D

@export var acceleration : float = 1
@export var deacceleration : float = 0.1
var acceleration_velocity : Vector2

func calculate_velocity(
		direction:Vector2 = Vector2.ZERO,
		body:CharacterBody2D = null,
		delta:float = 1.0
	)->Vector2:
	var new_velocity:Vector2 = body.velocity
	var speed:float = get_speed()
	var forces_velocity:Vector2 = calculate_forces_velocity(body,delta)
	
	
	
	if direction != Vector2.ZERO:
		new_velocity = new_velocity.move_toward(
			direction*get_speed(),get_speed()*acceleration
		)
		#new_velocity += direction * speed * acceleration
		#if new_velocity.length() > base_speed * (sprint_strength+1):
		#	new_velocity = direction * speed
		new_velocity += forces_velocity
	else:
		if (new_velocity.length() > deacceleration * base_speed):
			new_velocity += -new_velocity.normalized() * deacceleration * base_speed
		else:
			new_velocity = Vector2.ZERO
		new_velocity += forces_velocity
	
	return new_velocity
