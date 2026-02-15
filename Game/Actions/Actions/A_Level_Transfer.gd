class_name A_Level_Transfer extends Base_Action

#some var and such may not be used any more
#might decide to keep this simple and just switch levels
#while also managing exit data and such

@export var level_uid : String

##This will allow spawn_location to be used in levels
##that allows overriding it
@export var override_spawn_location: bool = false
##This withh use the vector stored with this is
##instead of the vector provided by spawn_location
@export var spawn_point_id : String = ""
##set the pawn in the new level to this position if 
##overrided and supported in that level
@export var spawn_location : Vector2 
@export var spawn_offset : Vector2 
@export var store_exit_point: bool = false

@export var exit_point_id:String = ""

@export var spawn_index : int = 0

@export var world_state : World_State = World_State.get_default_instance()
@export var player_state : Player_State = Player_State.get_default_instance()

func _run(action_state:Action_State) -> bool:
	print_debug('running level transfer to :', level_uid)
	if level_uid.is_empty():
		print_debug('no level uid provided')
		return false
	if action_state == null:
		print_debug('no vaild action state')
		return false
	if action_state.owner as Node2D:
		var old_location : Vector2 = action_state.owner.global_position
		if store_exit_point:
			player_state.set_vector(exit_point_id+"_location",old_location)
			#player_state.positions[entry_point_id+"_location"] = old_location
		if (action_state.owner as Character2D):
			player_state.exit_data.facing_direction = action_state.owner.facing_direction
			player_state.exit_data.entry_velocity = action_state.owner.velocity
		player_state.exit_data.previous_level = world_state.level_uid
		player_state.exit_data.previous_position = old_location
		player_state.exit_data.override_entry_position = override_spawn_location
		player_state.exit_data.entry_position = spawn_location
		if spawn_point_id != '':
			if (player_state.has_vector(spawn_point_id+"_location")):
				player_state.exit_data.entry_position = player_state.get_vector(spawn_point_id+"_location",2,false)
		player_state.exit_data.entry_offset = spawn_offset
	else:
		print_debug('owner is not a node2d')
		#may not want to return if not node2d?
		return false
	#player_state.exit_data.entry_diection
	player_state.exit_data.target_level = level_uid
	world_state.load_level(level_uid,World_State.TRANSFER_TYPE.EXIT)
	print_debug('transfer sucess? ', level_uid,' | ', world_state.transfer_type)
	#print_debug('world_state: ', world_state, 'connections',world_state.load_level.get_connections())
	print_debug(player_state)
	return super(action_state)
