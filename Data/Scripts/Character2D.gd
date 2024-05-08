class_name Character2D extends CharacterBody2D

#TODO: redo the parametters. attacked should return what was attack, the pawn(self), and
#either data or somekind of ref that can be used to create the data
#same interacted. handler not nessary since the handler will be the one listening in
#NOTE: may use a node like interaction component and just check for the class
#then the action can be grab or perform there. interactions as only actions may not works
#unless a subsystem is design to handle it such as the fishing game need to be able to
#let the owner know if a fish is caught. could add the owner to data and have an action to run when fish is
#caught. (optional action 1 add the fish, but this logic may be built in0 action(2) will remove the owner
#or set it on a time out (invisable and uninteractable
signal attacked(attacker, target, data)
#passive interaction
signal interacted(instigator, interactee, data) #NOTE interactee is currently the interact componet
#Note: could make a export add to meta data, but only works for objects with scripts

#NOTE: this should be used for anything that can be controlled by a controller
#It should have a facing vector, func to call to trigger attacks, interactions, or actions
#and signals to notify controller of the results of the attakck/interactions
#also need a way to give it movement comands. move(currenly have one) and move_to
#(need one for AI. this means a point is set and the AI will move to it). 
#everything else the child should be able to do. 
#movement componet may need to change a little. just need something that handles
#processing the commands for the case of AI or pathfinding without knowing much of the logic
#could make another componet or node called brain. it would be told positions and stuff 
#and run to move_to logic base on the data provided. also could use metadata to store that data
#and have the child check it self and run the logic that way. 
#movement componet is just a way to swap out how the character will move per tick or 
#in other words how the velocity will change

@export var movement_component : Movement_Component_2D = Advance2DMovement.new()
#@export var interaction_component : Interactive_Data

@onready var sprite = $Sprite2D


func attack()->void:
	#NOTE: this will tell the character do the attack logic so the controller do not
	#have to know about variations of attack
	#NOTE: switching attacks would mean there is one active attack that get switch by other means
	#that not nessary a responsibility of the controller(but could be due to processing input)
	#so a system to handle that may be needed
	pass
func interact()->void:
	#NOTE: this is to isolate the interaction cast from controller to fine tune
	#how it will be triggered. a signal will be used to listen for interaction if there is one
	pass


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


