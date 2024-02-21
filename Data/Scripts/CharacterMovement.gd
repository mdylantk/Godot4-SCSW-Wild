class_name CharacterMovement extends CharacterBody2D

@export var speed : float = 32
@export var acceleration : float = 1
@export var deacceleration : float = 1
@export var sprint_modifier : float = 2.5
@export var sprint_strength : float = 0
@export var facing_dirction : Vector2 = Vector2.RIGHT

#@export var slide : bool = false #allow faking sliding, allowing velocity to either slowly decrease or not decrease--

#TODO: in the future, having a resource to load sprite  and other varibles
#may be better so similar nodes could be reused or changed
@onready var sprite = $Sprite2D

#TODO: movemnt may change on map type. so either pawn or movement will be switch out
#the player_handler should handle the switching, but how the logic will be help
#still need to be decided. either share a movement node or have swapable logic
#for one movement node

var last_velocity : Vector2 #for caculating facing direction or other conditions


func _physics_process(_delta) :
	
	if velocity != Vector2.ZERO :
		move_and_slide()
		if (velocity.length() > speed * acceleration and 
			velocity.length() > deacceleration * speed
		):
			velocity += -velocity.normalized() * deacceleration * speed
		else:
			velocity = Vector2.ZERO
	
	
	
	if sprite != null :
		if facing_dirction.x < 0 :
			sprite.flip_h = true
		elif facing_dirction.x > 0: 
			sprite.flip_h = false
	
	#just a flag saying there was input last frame
	last_velocity = velocity

#this is simple and will override any movement that been set. basily a handler(player or ai) can tell it to move
#in a dir every physic update. may also have a move to location task, but then again the handler could do that
func move(direction : Vector2):
	if direction != Vector2.ZERO:
		facing_dirction = direction
		#TODO:Sprint need to be controlled on the player handler. 
		#direction *= (1+Input.get_action_strength("Sprint")*sprint_modifier)
		direction *= (1+sprint_strength*sprint_modifier)
		#NOTE: speed is acceration atm
		#acceration increase velocity
		#overtime deacceration/breaking/friction will reduce velocity to 0 overtime
		velocity += direction * speed * acceleration
		if velocity.length() > speed * sprint_modifier:
			velocity = direction * speed 
		#velocity.ceil()
		return true
	else:
		return false


