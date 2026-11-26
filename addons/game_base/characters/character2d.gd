class_name Character2D extends Node2D

#NOTE: brain, controller, movement, and save state should stay
#need to clean up and try finishing the base components
#TODO: see if there a way to move movement states? or not
#have an enum or depend on a enum in the base class

#TODO: the parameters may need to change. could reduce to data or change the type (target to targets)
#TODO: maybe not have these in the base class?  on_action_triggered could replace it
signal attacked(attacker, target, data)
signal interacted(instigator, interactee, data)

signal facing_changed(new_facing:Vector2, old_facing:Vector2)
signal movement_state_change(new_value:MovementStates, old_value:MovementStates, direction:Vector2)

#decided how save states work for base character. load and save could be added and do nothing
#and have player and things override them or leave them out for group call or something
signal character_state_changed(old_state: State, new_state: State)

signal body_moved(body : PhysicsBody2D, old_position:Vector2, difference:Vector2)

enum MovementStates { IDLE, STOPPED, WALKING, SPRINTING, TURNING }

#NOTE: Moving game state ref to characters that save or need it
#might be good to think about ways to have saving slotable.

@export var body : PhysicsBody2D
##This is for caculate velocity change and store varibles related to how it change
@export var movement_component : Movement_Component_2D = get_default_movement_component():
	set(value):
		#This will make a copy incase a tres ref was used. The component may
		#have some values that change such as the sprint strength.
		movement_component = value.duplicate()

@export var facing_direction : Vector2 = Vector2.RIGHT :
	set (value):
		if facing_direction != value:
			facing_changed.emit(value, facing_direction)
			facing_direction = value
##this will duplicate the character state 
##on ready or when ever the state is changed if true.
@export var clone_character_state: bool
@export var character_state : State:
	set(value):
		#NOTE: this may not be called if a default is assigned
		#also should handle null state or have it create a generic one if null
		var old_state = character_state
		if (value):
			if (value.template_state or clone_character_state):
				#states should try not to have resources that need to be clone on dup
				#if it dose, then an additonal call will be needed or deep set to true if all cases needs to be clone
				character_state = value.duplicate()
				character_state_changed.emit(old_state,value)
				return
		character_state = value
		character_state_changed.emit(old_state,value)

#func character_state_changed(old_state: State, new_state: State) :
#	pass



##allow children character to override the default movement component
func get_default_movement_component()->Movement_Component_2D:
	return Movement_Component_2D.new()


var movement_state : MovementStates = MovementStates.IDLE:
	set(value):
		if movement_state != value:
			movement_state_change.emit(value,movement_state,facing_direction)
			movement_state = value
			

#may keep the brain for more control for the base character, but it might be changed to a resource
#func brain_assigned(new_brain:Base_Brain):
#	new_brain.action_triggered.connect(on_action_triggered)
#	pass
#func brain_unassigned(old_brain:Base_Brain):
#	old_brain.action_triggered.disconnect(on_action_triggered)
#	pass

func get_inventory()->Advance_Inventory:
	return null

##called when a character state is set/assign/loaded
##used to extract data from it that is handled outside the state
func character_state_loaded():
	pass

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

##an overrided for getting a directional vector. The character may use a brain
##or input to move and the logic of that should be set here
func get_move_direction()->Vector2:
	return Vector2()

func update_movement_state(direction: Vector2):
	if direction != facing_direction:
		movement_state = MovementStates.TURNING
		if direction != Vector2.ZERO:
			facing_direction = direction 
	var velocity: Vector2
	if body is RigidBody2D:
		velocity = body.linear_velocity
	if body is CharacterBody2D:
		velocity = body.velocity
	if velocity != Vector2.ZERO:
		if movement_component.sprint_strength > 0:
			movement_state = MovementStates.SPRINTING
		else:
			movement_state = MovementStates.WALKING
	else:
		if direction == Vector2.ZERO:
			movement_state = MovementStates.IDLE
		else:
			movement_state = MovementStates.STOPPED
			
func _body_moved(body : PhysicsBody2D,old_position:Vector2, difference:Vector2):
	#sync position by default. can always override this to disable it
	if (difference != Vector2.ZERO):
		global_position += difference
		body.position = old_position
	body_moved.emit(body, old_position, difference)
			
#this is simple and will override any movement that been set. basily a handler(player or ai) can tell it to move
#in a dir every physic update. may also have a move to location task, but then again the handler could do that
func move(delta:float = 1.0):
	var direction = get_move_direction()
	var old_position = body.position
	var moved = movement_component.move(direction,body,delta)
	if moved:
		_body_moved(body, old_position, body.position - old_position)
	update_movement_state(direction)
	return moved
	


func on_action_triggered(action:String, value:float)-> void:
	if action == "Sprint":
		movement_component.sprint_strength = value
		pass
	if action == "Interact":
		print_debug("MEOOW?")
		interact()
		pass
	if action == 'Jump':
		movement_component.jump(body)

func _physics_process(delta: float) -> void:
	if (!body || !movement_component):
		return
	move(delta)
	
