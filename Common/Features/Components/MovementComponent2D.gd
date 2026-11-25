##This is to allow movement logic to be esaier to reuse and swap out
class_name Movement_Component_2D extends Resource

#TODO: Decide if most var should keep their dedicated getters or acess them directly
#they are there so later one could add callables to modify the propery instead of 
#modifing the export properties
#in short, this may be something to make a c++ base for keeping the base use fast
#then extending it to take callables to modify values dynamicly
#also could rename the exports to defaults and have the extentsions add a dynamic value 
#if it uses it or add the getter instead to speed up this base class
#also can split the top down and platformer logic in diffrent extensions but will mean 
#dulip logic (such if both want to use advance movement)
#also should add back in base speed, but do not use move_towarge, but use the
#diffrence between velocity length and max speed (and maybe use a diffrent velocity
#like in advance to isolate from the total velocity)
 

#@export var base_speed : float = 64
@export var max_speed : float = 100
#@export var acceleration : float = 1000
##this is how much sprint will modify the speed
##The exact way would be what is declare in get_speed() or other functions.
@export var sprint_modifier : float = 1.0
@export_range(-1, 1) var vertical_direction:int = 1
@export_range(-1, 1) var horizontal_direction:int = 1
@export var enable_jump : bool = false
@export var jump_force : float = 100
@export var jump_counter_gravity : float = 1.0
@export var push_force : float = 100
@export var enable_gravity : bool = false
##a way to fake being on floor for 2d top-down to share logic between the two systems
##it also can be use as an on_floor flag for top-down
@export var always_on_floor : bool = false
var jump_velocity: Vector2
var jumped:bool


##This is the sprint flag, but it is a float incase it needs to be handle as
##an input strength
var sprint_strength : float = 0.0

func remap_direction(direction:Vector2):
	return (direction * Vector2(horizontal_direction,vertical_direction))

func can_jump(body:PhysicsBody2D) -> bool:
	return is_on_floor(body) and enable_jump

#func get_speed()->float:
#	return (sprint_modifier*sprint_strength+1)*base_speed
func get_sprint_factor()->float:
	return sprint_modifier*sprint_strength+1

func get_max_speed()->float:
	return max_speed
	
func get_jump_force()->float:
	return jump_force + (jump_counter_gravity*get_gravity())
	
func get_push_force()->float:
	return push_force

#var on_floor:bool = false

func is_on_floor(body:PhysicsBody2D):
	if always_on_floor:
		return true
	if (body as CharacterBody2D):
		return body.is_on_floor()
	return false

func jump(body:PhysicsBody2D, up_direction:Vector2 = Vector2.UP)->bool:
	if(can_jump(body)):
		jump_velocity = up_direction*get_jump_force()
		jumped = true
		return true
	return false

func get_gravity() -> float:
	return ProjectSettings.get_setting("physics/2d/default_gravity", 0)
func get_gravity_direction()->Vector2:
	return ProjectSettings.get_setting("physics/2d/default_gravity_vector", Vector2.ZERO)

func apply_gravity(direction:Vector2, body:PhysicsBody2D, delta:float=1.0)-> bool:
	if (enable_gravity and !is_on_floor(body)):
		if (body as CharacterBody2D):
			var gravity: float = get_gravity()
			var gravity_direction: Vector2 = get_gravity_direction()
			body.velocity += gravity_direction * gravity
			return true
	return false
	
func apply_forces(direction:Vector2, body:PhysicsBody2D, delta:float=1.0)-> bool:
	if (enable_jump):
		if (body as CharacterBody2D):
			body.velocity += jump_velocity
			if (is_on_floor(body) and !jumped):
				jump_velocity = Vector2.ZERO
			elif(jump_velocity.length() < 1):
				jump_velocity = Vector2.ZERO
			else:
				jump_velocity *= (1-delta*(get_jump_force()/(jump_velocity.length()+1)))
				jumped = false
			return true
	return false
func apply_velocity(direction:Vector2, body:PhysicsBody2D, delta:float=1.0) -> bool:
	if (body as CharacterBody2D):
		if (is_on_floor(body)):
			body.velocity = direction * get_max_speed() * get_sprint_factor()
		else:
			body.velocity = direction * get_max_speed()
		return true
	return false

func apply_push(body:PhysicsBody2D, delta:float=1.0):
	if (body as CharacterBody2D):
		var force : float = get_sprint_factor() * get_push_force() if is_on_floor(body) else get_push_force()
		for i in body.get_slide_collision_count():
			var other_body = body.get_slide_collision(i)
			if other_body.get_collider() is RigidBody2D:
				other_body.get_collider().apply_central_force(
					-other_body.get_normal() * force
				)

func move(direction:Vector2, body:PhysicsBody2D, delta:float=1.0):
	var remapped_direction :Vector2 = remap_direction(direction)
	apply_push(body, delta)
	var moved = apply_velocity(remapped_direction,body,delta)
	apply_forces(remapped_direction,body,delta)
	apply_gravity(remapped_direction,body,delta)
	if (body as CharacterBody2D):
		body.move_and_slide()
	return moved
