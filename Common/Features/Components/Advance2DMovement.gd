class_name Advance2DMovement extends Movement_Component_2D

@export var acceleration : float = 256
#NOTE TODO: should add an option to loose all acc velocity when colling with a wall
@export var deacceleration : float = 256
var acceleration_velocity : Vector2


@export var max_jumps : int = 3
var jumps : int = 0

		
func move(direction:Vector2,body:PhysicsBody2D,delta:float=1.0):
	var moved: bool = super(direction, body, delta)
	if is_on_floor(body) and jumps > 0:
		jumps = 0
	return moved

#func get_jump_force()->float:
#	return jump_force

func can_jump(body:PhysicsBody2D, up_direction = Vector2.UP) -> bool:
	if !enable_jump:
		return false
	if !is_on_floor(body) and jumps >= max_jumps:
		return false
	return true

func jump(
	body:PhysicsBody2D = null,
	up_direction:Vector2 = Vector2.UP
)->bool:
	if (!super(body,up_direction)):
		return false 
	jumps += 1
	return true

func apply_velocity(direction:Vector2, body:PhysicsBody2D, delta:float=1.0) -> bool:
	if (body as CharacterBody2D):
		if (direction == Vector2.ZERO):
			acceleration_velocity = acceleration_velocity.move_toward(Vector2.ZERO,deacceleration*delta)
		else:
			if (is_on_floor(body)):
				acceleration_velocity = acceleration_velocity.move_toward(
					direction * get_max_speed() * get_sprint_factor(),
					acceleration*get_sprint_factor()*delta
					)
			else:
				acceleration_velocity = acceleration_velocity.move_toward(
					direction * get_max_speed(),
					acceleration*delta
					)
			
		body.velocity = acceleration_velocity
		return true
	return false
