class_name Advance2DMovement extends Movement_Component_2D

@export var acceleration : float = 1
@export var deacceleration : float = 0.1
var acceleration_velocity : Vector2
##this is a test to try out gravity and platforming
@export var is_platformer : bool = false
##a way to test gravity values
@export var gravity: Vector2 = Vector2(0.0,64.0)

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
	var speed:float = get_speed()
	var forces_velocity:Vector2 = calculate_forces_velocity(body,delta)
	
	
	
	if new_direction  != Vector2.ZERO:
		new_velocity = new_velocity.move_toward(
			new_direction*get_speed(),get_speed()*acceleration
		)
		#new_velocity += direction * speed * acceleration
		#if new_velocity.length() > base_speed * (sprint_strength+1):
		#	new_velocity = direction * speed
		new_velocity += forces_velocity
	else:
		new_velocity = new_velocity.move_toward(
			Vector2.ZERO,get_speed()*deacceleration
		)
		#if (new_velocity.length() > deacceleration * base_speed):
		#	new_velocity += -new_velocity.normalized() * deacceleration * base_speed
		#else:
		#	new_velocity = Vector2.ZERO
		new_velocity += forces_velocity
	
	return new_velocity

func apply_forces(
	body:CharacterBody2D = null,
	delta:float=1.0
)->void:
	if jump_velocity != Vector2.ZERO:
		jump_velocity = jump_velocity.move_toward(Vector2.ZERO,1.0+jumps)
	if !body.is_on_floor() and gravity_enable():
		gravity_velocity = gravity_velocity.move_toward(get_gravity(),1.0)
	else: 
		gravity_velocity = Vector2.ZERO
	force_velocity = force_velocity.move_toward(Vector2.ZERO,1.0)
	
	if body.is_on_floor() and jumps > 0:
		jumps = 0

func gravity_enable()->bool:
	return is_platformer
	
func get_gravity()->Vector2:
	return Vector2(0.0,64.0)
	
func jump(
	body:CharacterBody2D = null,
	up_direction:Vector2 = Vector2.UP
)->bool:
	if !gravity_enable():
		return false
	if body:
		if !body.is_on_floor() and jumps >= max_jumps:
			return false
	#could also apply wall normal for wall jump
	jump_velocity += get_jump_force()*up_direction 
	jumps += 1
	return true
