extends Tilemap_Handler

@export var player_state : Player_State = Player_State.get_default_instance()
@export var world_state : World_State = World_State.get_default_instance()

func _ready() -> void:
	#%Player.brain = Player.controller_brain
	#TODO: the player position may be in the state or in the exit data
	#need to decide which is better
	#var player_pos : Vector2
	#if (player_state.has_vector("old_man_house_location")):
	#	player_pos = player_state.get_vector("old_man_house_location",
	#		2, false
	#	)
	#	%Player.position = player_pos
	#pass
	
	match world_state.transfer_type :
		0:
			pass
		1:
			if (player_state.has_vector('pawn_position')):
				%Player.global_position = player_state.get_vector('pawn_position',2,false)
			if (player_state.has_vector('pawn_facing')):
				%Player.facing_direction = player_state.get_vector('pawn_facing',2,false)
		2:
			if (player_state.has_vector('old_man_house_location')):
				%Player.global_position = player_state.get_vector('old_man_house_location',2,false)
