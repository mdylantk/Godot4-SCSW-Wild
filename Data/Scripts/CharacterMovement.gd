class_name CharacterMovement extends CharacterBody2D

#TODO: rename this to Character2D or something that means controllable Character
#most of the logic here(outside of components and node) should help in navigating


@export var movement_component : Movement_Component_2D = Advance2DMovement.new()

#@export var slide : bool = false #allow faking sliding, allowing velocity to either slowly decrease or not decrease--

#TODO: in the future, having a resource to load sprite  and other varibles
#may be better so similar nodes could be reused or changed
@onready var sprite = $Sprite2D

func update_sprite() :
	if sprite != null :
		if movement_component.facing_dirction.x < 0 :
			sprite.flip_h = true
		elif movement_component.facing_dirction.x > 0: 
			sprite.flip_h = false

#this is simple and will override any movement that been set. basily a handler(player or ai) can tell it to move
#in a dir every physic update. may also have a move to location task, but then again the handler could do that
func move(direction : Vector2):
	velocity = movement_component.update_velocity(velocity,direction)
	if velocity != Vector2.ZERO:
		move_and_slide()
		update_sprite()
		return true
	else:
		return false


