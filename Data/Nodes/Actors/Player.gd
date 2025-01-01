extends Character2D

#@export var interact_cast : ShapeCast2D

@onready var inventory = $Inventory


#NOTE attack may need to be realted to a node or something. attack dection 
#mosty likly will change so one shapecast wont solve all the conditions.
#so a cast or projectile would be used. the node will be responsible in singeling back hit results
#and triggered by the attack call. interaction could work the same 

func _ready()->void:
	movement_component.facing_change.connect(on_facing_changed)
	movement_state_change.connect(on_movement_state_change)
	
	character_state.saving.connect(on_state_saving)
	character_state_loaded() #handling it here since the setter may
	#get called before it is ready
	#TODO: have state loaded called on ready if state not null
	#AND only have it called in setter if getr_tree == null
	#then it should be unlikly to be called twice

func on_state_saving():
	if inventory != null:
		character_state.set_meta("inventory",inventory.inventory)

func character_state_loaded():
	if inventory != null and character_state != null:
		inventory.inventory = character_state.get_meta("inventory",inventory.inventory)

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

#func interact():
#	$Shaped_Interactor.interact()



#func _on_shaped_interactor_interaction(interactor: Node, interactee: Node, data: Dictionary) -> void:
#	interacted.emit(interactor, interactee,data)
