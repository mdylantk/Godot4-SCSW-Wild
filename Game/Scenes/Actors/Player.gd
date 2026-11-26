extends Character2D

#@export var interact_cast : ShapeCast2D
@export var player_state:Player_State = Player_State.get_default_instance()
@export var game_state : Game_State = Game_State.get_default_instance()
#TODO: may remove inventory as a node so the save_state can store it
#there no reason to have two copies of an item array. an inventory object
#may still be used since the functions are needed and other stats like limits
#also a node can still be useful for providing item drops or static loadouts
#but any persistant/dynamic inventory would need to be redirected to the save state.
#@onready var inventory = $Inventory

var passing = false:
	set(value):
		if (passing != value):
			passing = value
			if(body):
				body.set_collision_mask_value(2,!passing)

#func get_inventory()->Inventory:
#	return $Inventory

func _ready()->void:
	facing_changed.connect(on_facing_changed)
	movement_state_change.connect(on_movement_state_change)

	%Shaped_Interactor.interaction.connect(on_interaction)

	%Brain.action_triggered.connect(on_action_triggered)
	
	
	#NOTE: direction in exitdata is more for spawning so it is for the
	#level to process
	facing_direction = player_state.exit_data.facing_direction
	$CharacterBody2D.velocity = player_state.exit_data.entry_velocity
	
	
	game_state.save_event.connect(on_autosave)
	game_state.load_event.connect(on_game_loaded)
	on_game_loaded(game_state.get_save_path())

func get_default_movement_component()->Movement_Component_2D:
	return Advance2DMovement.new()

	
#NOTE: may need a class level save object so the data can be extracted
#or saved. could also split the saving and loading into functions
#and then call it to get acess the the instance or give the instance
func on_autosave(path : String = ""):
	player_state.set_vector('pawn_position',body.global_position)
	player_state.set_vector('pawn_facing',facing_direction)
	

func on_game_loaded(path : String = ""):
	pass

func on_movement_state_change(new_value:MovementStates, old_value:MovementStates, direction:Vector2):
	if direction.x < 0 :
		%AnimationPlayer.play("left")
	elif direction.x > 0: 
		%AnimationPlayer.play("right")
	
	match new_value:
		MovementStates.IDLE:
			%AnimationPlayer.play("idle")
		MovementStates.SPRINTING:
			%AnimationPlayer.speed_scale = 2
			%AnimationPlayer.queue("walk")
		MovementStates.WALKING:
			%AnimationPlayer.speed_scale = 1
			%AnimationPlayer.queue("walk")
		MovementStates.STOPPED:
			%AnimationPlayer.play("walk",-1,0)
	return


func on_facing_changed(new_facing:Vector2,old_facing:Vector2):
	#update the spite to indicate hit direction
	#$Direction.position = new_facing * 12
	#interact_cast.target_position = new_facing * 24
	
	%Shaped_Interactor.look_at((new_facing)+%Shaped_Interactor.global_position)
	#NOTE: move this here so that Character2D wont need to depend on
	#sprite2d. the issue is that this logic need to be applied to anything that want to use it
	#but can just subtype sprite enities and animate sprite enities if needed\


func interact():
	%Shaped_Interactor.interact(self)

func on_interaction(source_pawn:Node, collider:Node, data:={}):
	var interaction : Interactive_Component = collider as Interactive_Component
	if interaction != null:
		player_state.player_debug_message = 'last interact: ' + str(interaction)
		#NOTE: will keep the old way, but may add it to base
		#character? a few interactions types like attack, use, cast
		#then have the shape or settings used declared in the child
		var interaction_data = interaction.interact(self,collider,data)
	else:
		player_state.player_debug_message = ''

func get_move_direction() -> Vector2:
	return %Brain.get_move_direction(body.position)


func move(delta=1.0):
	#NOTE: Still not syncing with sprint
	#var sprint_state = %Brain.get_action_state("Sprint")
	#movement_component.sprint_strength =  sprint_state if sprint_state else 0.0
	var direction:Vector2 = get_move_direction()
	if body is CharacterBody2D:
		player_state.player_debug_message = (
			"\n d "+str(direction) + 
			" \n v " +str(body.velocity)+ 
			" \n jv " +str(movement_component.jump_velocity) 
		)
	if body is RigidBody2D:
		player_state.player_debug_message = str(direction) + str(body.linear_velocity)
		
	if (direction.y > 0):
		passing = true
	else:
		passing = false
	super(delta)
	
