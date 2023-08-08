class_name CharacterMovement extends CharacterBody2D

@export var speed : float = 32
@export var sprint_modifier : float = 2.5
@export var use_input : bool = true
@export var facing_dirction : Vector2 = Vector2.RIGHT
#@export var slide : bool = false #allow faking sliding, allowing velocity to either slowly decrease or not decrease--

@onready var sprite = $Sprite2D

var last_velocity : Vector2 #for caculating facing direction or other conditions

func _physics_process(_delta) :
	last_velocity = velocity
	if use_input : 
		var input_dir = Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
		if input_dir != Vector2.ZERO:
			facing_dirction = input_dir
		input_dir *= (1+Input.get_action_strength("Sprint")*sprint_modifier)
		velocity = input_dir * speed
	if velocity != Vector2.ZERO :
		move_and_slide()
		
	if sprite != null :
		if facing_dirction.x < 0 :
			sprite.flip_h = true
		elif facing_dirction.x > 0: 
			sprite.flip_h = false

