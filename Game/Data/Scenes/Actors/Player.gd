extends Character2D

#@export var interact_cast : ShapeCast2D

#TODO: make a getter function and let the children assign some kind of inventory
#to return. may be better to have the inventory more self contained though
#having a getter that return some node with item getting and setting functionality
#is still better
@onready var inventory = $Inventory

func get_inventory()->Inventory:
	return $Inventory

#NOTE attack may need to be realted to a node or something. attack dection 
#mosty likly will change so one shapecast wont solve all the conditions.
#so a cast or projectile would be used. the node will be responsible in singeling back hit results
#and triggered by the attack call. interaction could work the same 

func _ready()->void:
	#NOTE: can load it, but some data is loss when switching scene (inventory)
	#so state is not being saved at the right time nore loaded. signal issues may
	#play a party to. Would need to remake the whole state system to not depend
	#on the state of the exported state
	#character_state = Data.load_resource("playerCharacterState",Data.default_path)
	#if character_state:
	#	pass
	#else:
	#	character_state = Character_State.new()
	super()
	movement_component.facing_change.connect(on_facing_changed)
	movement_state_change.connect(on_movement_state_change)
	#if character_state:
	#	character_state.saving.connect(on_state_saving)
	#	character_state_loaded() #handling it here since the setter may
	#get called before it is ready
	#TODO: have state loaded called on ready if state not null
	#AND only have it called in setter if getr_tree == null
	#then it should be unlikly to be called twice
	%Shaped_Interactor.interaction.connect(on_interaction)
	#NOTE: controller is most likly already assign, so would
	#need to call the assign logic else none of the connections will be applied
	if %Brain.controller:
		on_controller_assigned(%Brain.controller)
	%Brain.controller_assigned.connect(on_controller_assigned)
	%Brain.controller_unassigned.connect(on_controller_unassigned)
	

func on_state_saving():
	print_debug("saving")
	if inventory != null:
		character_state.set_meta("inventory",inventory.inventory)
	if World.get_level_id():
		#NOTE TODO: the level should assign its own id and the scene tree
		#way is only used if they do not. by allowing them to set it,
		#they can disable saving of location related to their name
		#NOTE: can also have them set the level id to "instance" or something
		#so the level id is shared or add a flag that will remove
		#temp pos. ideally can just use location for temp points
		character_state.set_location(position)#,World.get_level_id())
	#character_state.set_location(position,get_path())
	#TODO: give world handler a function to return level id

func on_autosave(path : String = ""):
	print_debug("autosaving 2")
	if character_state != null:
		on_state_saving()
		Data.save_data(character_state,"playerCharacterState",path)

func on_game_loaded(path : String = ""):
	print_debug("MEOW@@@!!!!")
	character_state = Data.load_resource("playerCharacterState",path)

func on_state_loaded() -> void:
	print_debug("loading")
	if inventory != null and character_state != null:
		if character_state.has_meta("inventory"):
			inventory.inventory = character_state.get_meta("inventory",inventory.inventory)
	#if World.get_level_id():
		#NOTE: this is unrelible. old level stays too long and this get called before the
		#swicth. 
		#old system that let level assign location still works, so just add an exit data
		#and have level assign locations as needed or let world act as the middle man
		#and allow both to connect to signals and call a level ready signal
		#print_debug(World.get_level_id()," meow ", character_state.get_location(position))
		#position = character_state.get_location(position)#,World.get_level_id())
	#character_state.get_location(position,get_path())
#func character_state_loaded():
#	if inventory != null and character_state != null:
#		if character_state.has_meta("inventory"):
#			inventory.inventory = character_state.get_meta("inventory",inventory.inventory)

func on_movement_state_change(new_value:MovementStates, old_value:MovementStates, direction:Vector2):
	if direction.x < 0 :
		$AnimationPlayer.play("left")
	elif direction.x > 0: 
		$AnimationPlayer.play("right")
	
	match new_value:
		MovementStates.IDLE:
			$AnimationPlayer.play("idle")
		MovementStates.SPRINTING:
			$AnimationPlayer.speed_scale = 2
			$AnimationPlayer.queue("walk")
		MovementStates.WALKING:
			$AnimationPlayer.speed_scale = 1
			$AnimationPlayer.queue("walk")
		MovementStates.STOPPED:
			$AnimationPlayer.play("walk",-1,0)
	return
	if new_value == MovementStates.IDLE:
		$AnimationPlayer.queue("idle")
		#$AnimatedSprite2D.play("sit")
		#$AnimationPlayer.stop()
		$Shaped_Interactor.visible = false
	elif new_value == MovementStates.STOPPED:
		#$AnimatedSprite2D.play("default")
		#$AnimationPlayer.stop()
		$Shaped_Interactor.visible = true
	else:
		if new_value == MovementStates.SPRINTING:
			$AnimationPlayer.speed_scale = 2
		else:
			$AnimationPlayer.speed_scale = 1
		if old_value == MovementStates.IDLE:
			$AnimationPlayer.queue("walk")
			#$AnimatedSprite2D.play("default")
		elif old_value == MovementStates.STOPPED:
			$AnimationPlayer.queue("walk")
		$Shaped_Interactor.visible = true

func on_facing_changed(new_facing:Vector2,old_facing:Vector2):
	#update the spite to indicate hit direction
	#$Direction.position = new_facing * 12
	#interact_cast.target_position = new_facing * 24
	$Shaped_Interactor.look_at((new_facing)+$Shaped_Interactor.global_position)
	#NOTE: move this here so that Character2D wont need to depend on
	#sprite2d. the issue is that this logic need to be applied to anything that want to use it
	#but can just subtype sprite enities and animate sprite enities if needed\
	return
	
	#TODO: could have animation player handler fliping so this wont need to worry about
	#ref animated sprite 2d. 
	#may be able to assume then animation player and use keywords instead of
	#direcly accessing it (with overriding the functions if default too limiting
	if $AnimationPlayer != null :
		var last_animation: String = $AnimationPlayer.current_animation
		if new_facing.x < 0 :
			$AnimationPlayer.play("left")
			#$AnimatedSprite2D.flip_h = true
		elif new_facing.x > 0: 
			$AnimationPlayer.play("right")
			#$AnimatedSprite2D.flip_h = false

func interact():
	%Shaped_Interactor.interact(self)

func on_interaction(source_pawn:Node, collider:Node, data:={}):
	var interaction : Interactive_Component = collider as Interactive_Component
	if interaction != null:
		interaction.interact(Player,self,collider,data)

func get_move_direction() -> Vector2:
	return %Brain.get_move_direction(position,velocity)
#func _on_shaped_interactor_interaction(interactor: Node, interactee: Node, data: Dictionary) -> void:
#	interacted.emit(interactor, interactee,data)

#temp connections. brain should handle this more directly, but is here untill
#a character brain is created.
func on_controller_assigned(controller:Controller)->void:
	controller.action_triggered.connect(on_action_triggered)

func on_controller_unassigned(controller:Controller)->void:
	controller.action_triggered.disconnect(on_action_triggered)
	
func on_action_triggered(action:String, value:Variant)->void:
	if action == "Sprint":
		movement_component.sprint_strength = value
	if action == "Interact":
		interact()
