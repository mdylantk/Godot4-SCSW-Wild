extends Character2D

@export var interact_cast : ShapeCast2D

@onready var inventory = $Inventory

#NOTE attack may need to be realted to a node or something. attack dection 
#mosty likly will change so one shapecast wont solve all the conditions.
#so a cast or projectile would be used. the node will be responsible in singeling back hit results
#and triggered by the attack call. interaction could work the same 

func _ready()->void:
	movement_component.facing_change.connect(on_facing_changed)
	movement_state_change.connect(on_movement_state_change)
	
func on_movement_state_change(new_value:MovementStates, old_value:MovementStates):
	if new_value == MovementStates.IDLE:
		$AnimatedSprite2D.play("sit")
		$AnimationPlayer.stop()
	elif new_value == MovementStates.STOPPED:
		$AnimatedSprite2D.play("default")
		$AnimationPlayer.stop()
	else:
		if new_value == MovementStates.SPRINTING:
			$AnimationPlayer.speed_scale = 2
		else:
			$AnimationPlayer.speed_scale = 1
		if old_value == MovementStates.IDLE:
			$AnimationPlayer.play("movement")
			$AnimatedSprite2D.play("default")
		elif old_value == MovementStates.STOPPED:
			$AnimationPlayer.play("movement")

func on_facing_changed(new_facing:Vector2,old_facing:Vector2):
	#update the spite to indicate hit direction
	$Direction.position = new_facing * 12
	interact_cast.target_position = new_facing * 24
	#NOTE: move this here so that Character2D wont need to depend on
	#sprite2d. the issue is that this logic need to be applied to anything that want to use it
	#but can just subtype sprite enities and animate sprite enities if needed\
	
	if $AnimatedSprite2D != null :
		if new_facing.x < 0 :
			$AnimatedSprite2D.flip_h = true
		elif new_facing.x > 0: 
			$AnimatedSprite2D.flip_h = false

func interact():
	#also could try the has methood with a node ref. then that node can handle
	#the interaction stuff
	
	#NOTE: may need a way to cycle the list or nullify last interacted object
	#or just check for one. attacking on the other hand may need to do more
	if interact_cast == null: return
	interact_cast.force_shapecast_update()
	var results :Array = interact_cast.collision_result
	var data :={"source":self}
	if !results.is_empty():
		data["collider"] = results[0].collider
		data["collision_results"] = results
		if data["collider"].owner != null:
			data["target"] = data["collider"].owner
		else:
			data["target"] = data["collider"]
		interacted.emit(self, data["collider"],data)

