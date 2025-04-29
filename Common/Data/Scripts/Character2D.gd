class_name Character2D extends CharacterBody2D

#TODO: the parameters may need to change. could reduce to data or change the type (target to targets)
signal attacked(attacker, target, data)
signal interacted(instigator, interactee, data)

signal movement_state_change(new_value:MovementStates, old_value:MovementStates, direction:Vector2)

enum MovementStates { IDLE, STOPPED, WALKING, SPRINTING, TURNING }

##This is for caculate velocity change and store varibles related to how it change
@export var movement_component : Movement_Component_2D = Advance2DMovement.new()

var save_state : Character_State

#NOTE: maybe i am overthinking this. name should be good enough. level may save 
#the full state of all enemies on save and load likewise. can add them to a dir base on
#ownership
func get_save_path()->String:
	#NOTE: may want to expose this and use a format. level and name is needed
	#for dynamic types, but global types just need a name
	var save_path : PackedStringArray = get_path().get_concatenated_names().split("root/")
	if save_path.size() > 1:
		return save_path[1].split("/"+name)[0]
	return ""


func on_new_game(path:String = ""):
	save_state = Character_State.new()
	
#TODO: try not to depend on data functions if possible. They are useful,
#but should try to have this less dependent on things.
#also ready using the data default path is iffy if trying to decoup this
#could use a var for the default path and have the children pull from data
#or could have it lightly depend on it with a resource for path info
#but may need another path after the level loaded to load state
func on_game_loaded(path:String = ""):
	
	var full_path = path + get_save_path() + "/" + name + ".tres"
	if ResourceLoader.exists(full_path):
		save_state = ResourceLoader.load(full_path,"",0)

	if save_state == null:
		on_new_game(path)
		
func on_autosave(path : String = ""):
	
	var full_path = path + get_save_path()
	if !DirAccess.dir_exists_absolute(full_path):
		DirAccess.make_dir_recursive_absolute(full_path)
	full_path = full_path + "/" + name + ".tres"
	ResourceSaver.save(save_state, full_path)
	print_debug("autosaving")



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


#Note: need a better way to update self or have a func called when level ready
#or call load game for only level instances or just let the children handle 
#acessing global varibles
#func _ready() -> void:
	#on_game_loaded(Data.default_path)
		


func _physics_process(delta: float) -> void:
	move()
	
