class_name Character2D extends CharacterBody2D

#these signals are for owning handler to listen for events or for other
#nodes to listen to
#agressive interaction. may or may not be trigger with on_interaction
signal attacked(attacker, target, data)
#passive interaction
signal interacted(handler, instigator, interactee, data)


#TODO: rename this to Character2D or something that means controllable Character
#most of the logic here(outside of components and node) should help in navigating


@export var movement_component : Movement_Component_2D = Advance2DMovement.new()
@export var interaction_component : Interactive_Data

#@export var slide : bool = false #allow faking sliding, allowing velocity to either slowly decrease or not decrease--

#TODO: in the future, having a resource to load sprite  and other varibles
#may be better so similar nodes could be reused or changed
@onready var sprite = $Sprite2D

func on_interaction(handler, instigator, interactee, data):
	if interaction_component != null:
		interaction_component.interact(handler, instigator, interactee, data)
	interacted.emit(handler, instigator, interactee, data)
	
func on_attacked(attacker, target, data = {}):
	#data is infomation generated throughthe attack logic
	#so it should be populated as much as possible before being passed
	#example is damage done and infomation on damage and hit locations
	#TODO: decide if attack logic should be handle by a component or 
	#just overrided by the child
	attacked.emit(attacker, target, data)

func update_sprite() :
	if sprite != null :
		if movement_component.facing_dirction.x < 0 :
			sprite.flip_h = true
		elif movement_component.facing_dirction.x > 0: 
			sprite.flip_h = false

#this is simple and will override any movement that been set. basily a handler(player or ai) can tell it to move
#in a dir every physic update. may also have a move to location task, but then again the handler could do that
func move(direction : Vector2):
	if movement_component != null:
		velocity = movement_component.update_velocity(velocity,direction)
	if velocity != Vector2.ZERO:
		move_and_slide()
		update_sprite()
		return true
	else:
		return false


