extends Character2D

#@export var interact_cast : ShapeCast2D

#TODO: may remove inventory as a node so the save_state can store it
#there no reason to have two copies of an item array. an inventory object
#may still be used since the functions are needed and other stats like limits
#also a node can still be useful for providing item drops or static loadouts
#but any persistant/dynamic inventory would need to be redirected to the save state.
@onready var inventory = $Inventory

func get_inventory()->Inventory:
	return $Inventory

func _ready()->void:
	on_game_loaded(Data.default_path)
	movement_component.facing_change.connect(on_facing_changed)
	movement_state_change.connect(on_movement_state_change)

	%Shaped_Interactor.interaction.connect(on_interaction)

	if %Brain.controller:
		on_controller_assigned(%Brain.controller)
	%Brain.controller_assigned.connect(on_controller_assigned)
	%Brain.controller_unassigned.connect(on_controller_unassigned)


func get_save_path()->String:
	return "Characters"

func on_autosave(path : String = ""):
	if inventory != null:
		save_state.inventory = inventory.inventory
	save_state.local_position = position
	super(path)

func on_game_loaded(path : String = ""):
	super(path)
	await get_tree().process_frame
	if inventory != null and save_state != null:
		inventory.inventory = save_state.inventory

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
