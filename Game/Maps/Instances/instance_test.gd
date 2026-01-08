extends Tilemap_Handler

@export var player_state : Player_State = load('uid://c67c2fehtuhni')

func _ready() -> void:
	#%Player.brain = Player.controller_brain
	#TODO: the player position may be in the state or in the exit data
	#need to decide which is better
	var player_pos : Vector2
	if (player_state.has_vector("old_man_house_location")):
		player_pos = player_state.get_vector("old_man_house_location",
			2, false
		)
		%Player.position = player_pos
	pass
