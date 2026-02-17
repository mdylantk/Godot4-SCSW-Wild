class_name Movement_Component_2D extends Resource

#NOTE: Decided to pass a the body instead of figuring out a way to split
#the info form the body. A custom body (done in c++) would be more ideal so that
#the logic used for these possible infomation can be spit into an object to be pass
#around instead of cipong infomation every frame

#TODO: Maybe have a dedicated movement state (refcounted?) that
#the component uses for advances cases. it will hold the lastest collsion
#data and extra (dynamic) properties. that would allow this to be more than 
#a veclodity caculator and manage the pass state. NOTE: this is fine as long
#as there are dedicated characters. dedicated movement componets are for cases
#where one character is used by functions varies base on the componets used

@export var base_speed : float = 64

##this is how much sprint will modify the speed
##The exact way would be what is declare in get_speed() or other functions.
@export var sprint_modifier : float = 1.0
@export var jump_force : float = 64.0

##This is the sprint flag, but it is a float incase it needs to be handle as
##an input strength
var sprint_strength : float = 0.0

##Stored jump force to be comsume overtime as long as it is vaild
var jump_velocity : Vector2
##Stored gravity force to be used to decide on max gravity pull
var gravity_velocity : Vector2
##stored additional forces to be comsume overtime
var force_velocity : Vector2

##calculate the new velocity
##NOTE: Should not modify the body pass. Body should be
##treated as read only
func calculate_velocity(
		direction:Vector2 = Vector2.ZERO,
		body:CharacterBody2D = null,
		delta:float = 1.0
	)->Vector2:
	var new_velocity:Vector2 = body.velocity
	var forces_velocity:Vector2 = calculate_forces_velocity(body,delta)
	
	if direction != Vector2.ZERO:
		new_velocity = new_velocity.move_toward(
			direction*get_speed(),get_speed()
		) + force_velocity
	else:
		if forces_velocity == Vector2.ZERO:
			new_velocity = Vector2.ZERO
		else:
			new_velocity += force_velocity
	return new_velocity

#var player_state:Player_State = Player_State.get_default_instance()
##caculate what the forces would affect. Generally
##this will be added to the final velocity
##but advance cases might not use this if their logic require
##more controll over when and how.
func calculate_forces_velocity(
		body:CharacterBody2D = null,
		delta:float = 1.0
	)->Vector2:
		var new_velocity:Vector2 = Vector2()
		if jump_velocity != Vector2.ZERO:
			new_velocity += jump_velocity
		if !body.is_on_floor() and gravity_enable():
			new_velocity += gravity_velocity
		if force_velocity != Vector2.ZERO:
			new_velocity += force_velocity
		#player_state.player_debug_message = str(new_velocity)
		return new_velocity

##set the jump force. if body is passed,
##then it may use that to decide if it can jump
##As well as modify the direction
func jump(
	body:CharacterBody2D = null,
	up_direction:Vector2 = Vector2.UP
)->bool:
	if !gravity_enable():
		return false
	if body:
		if !body.is_on_floor():
			return false
	#could also apply wall normal for wall jump
	jump_velocity = get_jump_force()*up_direction
	return true

##add additional forces. Id is reserve for advance cases
##where forces may need to be split into more peices
func add_additional_force(
		force:float = 0.0,
		direction:Vector2 = Vector2.ZERO,
		id:String = ''
	)->void:
		force_velocity += direction*force

##apply all forces after velocity is caculated
##this will reduce forces velocity in most cases
func apply_forces(
	body:CharacterBody2D = null,
	delta:float=1.0
)->void:
	if jump_velocity != Vector2.ZERO:
		jump_velocity = jump_velocity.move_toward(Vector2.ZERO,1.0)
	if !body.is_on_floor() and gravity_enable():
		gravity_velocity = gravity_velocity.move_toward(get_gravity(),1.0)
	else: 
		gravity_velocity = Vector2.ZERO
	force_velocity = force_velocity.move_toward(Vector2.ZERO,1.0)

func get_speed()->float:
	return (sprint_modifier*sprint_strength+1)*base_speed
	
func get_jump_force()->float:
	return jump_force

##allow children to override this. by default
##falling and jumping will not be enable
func gravity_enable()->bool:
	return false

##get the gravity. allows children to override it
##should try to get the value from a global or shared (world) state
##the childen could also apply modifiers as well
func get_gravity()->Vector2:
	return Vector2(0.0,64.0)
