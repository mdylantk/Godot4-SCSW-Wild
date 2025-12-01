extends Tilemap_Handler

@export var player_state : Player_State = load('uid://c67c2fehtuhni')

func _ready() -> void:
	#%Player.brain = Player.controller_brain
	#TODO: the player position may be in the state or in the exit data
	#need to decide which is better
	var player_pos : Vector2
	if (player_state.positions.has("old_man_house_location")):
		player_pos = player_state.positions["old_man_house_location"] 
	#var player_pos = Savedata_Helper.fetch_player_position(Player,"old_man_house")
	if typeof(player_pos) == TYPE_VECTOR2: 
		if player_pos != Vector2.ZERO: 
			#NOTE: need to see if there one set
			#and not check for zero, but for now this is to test
			%Player.position = player_pos
	pass
