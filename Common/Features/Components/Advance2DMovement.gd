class_name Advance2DMovement extends Movement_Component_2D

@export var acceleration : float = 1
@export var deacceleration : float = 0.1

func update_velocity(velocity:Vector2, direction:Vector2 = Vector2.ZERO):
	var new_velocity:Vector2 = velocity
	var speed:float = get_speed()
	
	if direction != Vector2.ZERO:
		new_velocity += direction * speed * acceleration
		if new_velocity.length() > base_speed * (sprint_strength+1):
			new_velocity = direction * speed
	else:
		if (new_velocity.length() > deacceleration * base_speed):
			new_velocity += -new_velocity.normalized() * deacceleration * base_speed
		else:
			new_velocity = Vector2.ZERO
	
	return new_velocity
