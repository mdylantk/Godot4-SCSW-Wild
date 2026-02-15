extends Tilemap_Handler

@export var player_state : Player_State = Player_State.get_default_instance()
@export var world_state : World_State = World_State.get_default_instance()

func _ready() -> void:
	match world_state.transfer_type :
		World_State.TRANSFER_TYPE.LOAD:
			if (player_state.has_vector('pawn_position')):
				%Player.global_position = player_state.get_vector('pawn_position',2,false)
			if (player_state.has_vector('pawn_facing')):
				%Player.facing_direction = player_state.get_vector('pawn_facing',2,false)
		World_State.TRANSFER_TYPE.EXIT:
			if player_state.exit_data.override_entry_position:
				%Player.global_position = (
					player_state.exit_data.entry_position +
					player_state.exit_data.entry_offset
				)
			%Player.global_position += player_state.exit_data.entry_offset
			%Player.facing_direction = player_state.exit_data.facing_direction
			%Player.velocity = player_state.exit_data.entry_velocity
			#if (player_state.has_vector('old_man_house_location')):
			#	%Player.global_position = player_state.get_vector('old_man_house_location',2,false)
