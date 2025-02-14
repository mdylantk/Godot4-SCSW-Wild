extends Tilemap_Handler


func _ready() -> void:
	#%Player.brain = Player.controller_brain
	
	var player_pos = Savedata_Helper.fetch_player_position(Player,"old_man_house")
	if typeof(player_pos) == TYPE_VECTOR2: 
		if player_pos != Vector2.ZERO: 
			#NOTE: need to see if there one set
			#and not check for zero, but for now this is to test
			%Player.position = player_pos
