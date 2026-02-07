class_name A_Level_Transfer extends Base_Action

#some var and such may not be used any more
#might decide to keep this simple and just switch levels
#while also managing exit data and such

@export var level_uid : String
#not going to be used? can modify the player var if needed
@export var spawn_location : Vector2 
@export var store_entry_point: bool = false

@export var entry_point_id:StringName = "world"

@export var spawn_index : int = 0

@export var world_events : World_State = World_State.get_default_instance()
@export var player_state : Player_State = Player_State.get_default_instance()

func _run(action_state:Action_State) -> bool:
	if level_uid.is_empty():
		print_debug('no level uid provided')
		return false
	if action_state == null:
		return false
	if action_state.owner as Node2D:
		var old_location : Vector2 = action_state.owner.global_position
		if store_entry_point:
			player_state.set_vector(entry_point_id+"_location",old_location)
			#player_state.positions[entry_point_id+"_location"] = old_location
		if (action_state.owner as Character2D):
			player_state.exit_data.facing_direction = action_state.owner.facing_direction
			player_state.exit_data.entry_velocity = action_state.owner.velocity
		player_state.exit_data.entry_position = old_location
	else:
		#may not want to return if not node2d?
		return false
	#player_state.exit_data.entry_diection
	player_state.exit_data.target_level = level_uid
	world_events.load_level.emit(level_uid, spawn_index)
	return super(action_state)
