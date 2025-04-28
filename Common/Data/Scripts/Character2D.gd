class_name Character2D extends CharacterBody2D

#TODO: the parameters may need to change. could reduce to data or change the type (target to targets)
signal attacked(attacker, target, data)
signal interacted(instigator, interactee, data)

signal movement_state_change(new_value:MovementStates, old_value:MovementStates, direction:Vector2)

enum MovementStates { IDLE, STOPPED, WALKING, SPRINTING, TURNING }

##This is for caculate velocity change and store varibles related to how it change
@export var movement_component : Movement_Component_2D = Advance2DMovement.new()
	#if the movement component ever need to store mutable data,  it need to
	#be duplicate on set. for not it more of a static type for caculations
	#while this and the character state will be used or mutable data
	#controller also would have a state, but it acts as an interface to that state
	#and well controller need to be shared


#NOTE: the issue is that this can be saved. so this and the one in editor
#may be diffrent. might be better to have a save/load function in the state
#so that the tres file ref can be updated from the saved one
@export var character_state : Character_State :
	set(value):
		if value:
			if value.is_unique:
				#TODO: this may get saved and loaded in cases where a whole level
				#needs to save. then the save_id need to be something that represent the 
				#owner of the state.Idealy the level or owner would handle the save and load
				#calls or at least the id to link them.
				#for now the state will not have the load func called since 
				#there is no save feature that need to save dynamic objects
				handle_state_connections(character_state,true)
				character_state = value.duplicate()
				handle_state_connections(character_state,false)
			else:
				handle_state_connections(character_state,true)
				character_state = value
				handle_state_connections(character_state,false)
				#value.load_state()
			#NOTE the flag to use path still need to be used
			#this will be set for all states that rep a scene object(node)
			#but will only be used of the flag is set from the provided state
			if is_inside_tree(): 
				character_state.source_path = get_path()
			character_state_loaded()
			#value.load_state()
		else:
			handle_state_connections(character_state,true)
			character_state = value
			handle_state_connections(character_state,false)
			
func handle_state_connections(state: Character_State, is_disconnecting:bool = false):
	if state:
		if is_disconnecting:
			state.saving.disconnect(on_state_saving)
			state.loaded.disconnect(on_state_loaded)
		else:
			if !state.saving.is_connected(on_state_saving):
				state.saving.connect(on_state_saving)
			if !state.loaded.is_connected(on_state_loaded):
				state.loaded.connect(on_state_loaded)
				state.load_state() #if not connected, then it might not be loaded
				#NOTE: shared states could cause multi load requests and thus 
				#should try not to share states between characters unless they
				#override this to ignore load_states and let a handler manage it
				#such case is odd and unlikly, but load state need to be loaded
				#when state changed and character states are handled by the character
				#and thus that is their role
		
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
			


func brain_assigned(new_brain:Base_Brain):
	new_brain.action_triggered.connect(on_action_triggered)
	pass
func brain_unassigned(old_brain:Base_Brain):
	old_brain.action_triggered.disconnect(on_action_triggered)
	pass

func get_inventory()->Inventory:
	return null

##called when a character state is set/assign/loaded
##used to extract data from it that is handled outside the state
func character_state_loaded():
	pass
	
func on_autosave(path : String = ""):
	print_debug("autosaving")
	if character_state != null:
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

##an overrided for getting a directional vector. The character may use a brain
##or input to move and the logic of that should be set here
func get_move_direction()->Vector2:
	return Vector2()

#this is simple and will override any movement that been set. basily a handler(player or ai) can tell it to move
#in a dir every physic update. may also have a move to location task, but then again the handler could do that
func move():
	var direction : Vector2 = get_move_direction()
	##Note: this brain wont be use. make sure new logic is in get_movr_direction()
	#if brain != null:
	#	direction = brain.get_direction(position,velocity)
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

func on_action_triggered(action:String, value:float)-> void:
	if action == "Sprint":
		movement_component.sprint_strength = value
		pass
	if action == "Interact":
		print_debug("MEOOW?")
		#TODO have player have it own interactor or similar
		#this is an old system, so may just let the pawn handles it full
		#NOTE: Player hander was listen to pawn for interactions. so will
		#need to redirect that logic here and skip the listening part
		#can pass Player hander as the handler and it should still work
		#Player.pawns_interactor.interact(self)
		print_debug("meow")
		interact()
		pass

func on_state_saving() -> void:
	pass

func on_state_loaded() -> void:
	pass
	
func _ready() -> void:
	if character_state:
		character_state.source_path = get_path()
		handle_state_connections(character_state)
		on_state_loaded() #calling this here since the state may load on init
		#thus calling before signal connections
		


func _physics_process(delta: float) -> void:
	move()
	
#func _enter_tree() -> void:
#	print_debug("MEOW ENTERED TREE MEOOOW!")
#	if character_state:
		#update the path when enter tree. NOTE: this may be unrelible for saving
		#by path if node switches parents a lot. current system is not built for that
		#case (well except for save_id being a way to bypass it)
#		character_state.source_path = get_path()
#		print_debug("? ",character_state.source_path)
