class_name Character2D extends CharacterBody2D

#TODO: the parameters may need to change. could reduce to data or change the type (target to targets)
signal attacked(attacker, target, data)
signal interacted(instigator, interactee, data)

signal movement_state_change(new_value:MovementStates, old_value:MovementStates, direction:Vector2)

enum MovementStates { IDLE, STOPPED, WALKING, SPRINTING, TURNING }

##This if for caculate velocity change and store varibles related to how it change
@export var movement_component : Movement_Component_2D = Advance2DMovement.new()
@export var brain_component : Base_Brain = Base_Brain.new()
#@export var interaction_component : Interactive_Data
@export var character_state : Character_State :
	set(value):
		#this will force it to make a clone instead of a ref
		#The data assign should be static ref. the copy should
		#be safe to modify. Note: since the resource is an object,
		#can create a clone/load/setup function that will either duplicate() or load
		#from disk
		character_state = value.init_state()
		character_state_loaded()
 #TODO: this would need to be a ref
#to a resource for the state. would need to make an new instance of it so it 
#can be modified. can use setters for that. also the state could have id so it 
#can be saved. the id can allow the state to be stored in templates instead of data
#and data can handle the saving and loading of the state

var movement_state : MovementStates = MovementStates.IDLE:
	set(value):
		if movement_state != value:
			movement_state_change.emit(value,movement_state,movement_component.facing_dirction)
			movement_state = value
			
#trying to notify changes in movement. may allow additional mode but for now
#it idle and move 

##called when a character state is set/assign/loaded
##used to extract data from it that is handled outside the state
func character_state_loaded():
	pass
	
func autosave():
	character_state.save_state()

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


#this is simple and will override any movement that been set. basily a handler(player or ai) can tell it to move
#in a dir every physic update. may also have a move to location task, but then again the handler could do that
func move(direction : Vector2):
	direction = brain_component.get_direction(position,velocity,direction)
	if movement_component != null:
		if direction != movement_component.facing_dirction:
			movement_state = MovementStates.TURNING
		velocity = movement_component.update_velocity(velocity,direction)
	if velocity != Vector2.ZERO:
		move_and_slide()
		if get_last_slide_collision() != null:
			if get_last_slide_collision().get_remainder() != Vector2.ZERO:
				movement_state = MovementStates.STOPPED
				return true
		#get_last_slide_collision().get_remainder()
		if movement_component.sprint_strength > 0:
			movement_state = MovementStates.SPRINTING
		else:
			movement_state = MovementStates.WALKING
		return true
	else:
		movement_state = MovementStates.IDLE
		return false
	
func _physics_process(delta: float) -> void:
	if brain_component != null:
		##TODO: have the controller handle calling move
		#brain_component.get_direction(position,velocity)
		move(Vector2())
	
	
