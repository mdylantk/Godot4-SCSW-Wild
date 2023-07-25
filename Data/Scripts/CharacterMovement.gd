class_name CharacterMovement extends CharacterBody2D

@export var speed : float = 16
@export var use_input : bool = true
@export var facing_dirction : Vector2 = Vector2.RIGHT
#@export var slide : bool = false #allow faking sliding, allowing velocity to either slowly decrease or not decrease--

@onready var sprite = $Sprite2D

var last_velocity : Vector2 #for caculating facing direction or other conditions
#need to decide if mouce, facing, or both will effect facing direction
#could just have it face on input. could even handle that in global/player state/controller

func _physics_process(_delta) :
	last_velocity = velocity
	if use_input : 
		var input_dir = Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
		#need a way to have fake input for ncp. could have it check for a input vector if use_input is false(also need input to be filter out so on controller id)
		if input_dir != Vector2.ZERO:
			facing_dirction = input_dir
		input_dir *= (1+Input.get_action_strength("Sprint"))
		velocity = input_dir * speed
	if velocity != Vector2.ZERO :
		move_and_slide()
		
	if sprite != null : #not the best, assuming all face right by default
		if facing_dirction.x < 0 :
			sprite.flip_h = true
		elif facing_dirction.x > 0: #need to skip if x == 0 or it will flip right when moving forward/back
			sprite.flip_h = false
			
	#testing lower lever raytracing
	#var space_state = get_world_2d().direct_space_state 
	# use global coordinates, not local to node
	#var query = PhysicsRayQueryParameters2D.create(global_position, global_position+(facing_dirction*32))
	#query.exclude = [self]
	#var result = space_state.intersect_ray(query)
	#print(result)
