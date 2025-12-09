extends CanvasLayer

@export var enable_debug : bool = true

@export var game_state : Game_State = load('uid://cnbeqfpaumxj3')
@export var world_state : World_State = load('uid://b047ftosxvj7p')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var debug := %Debug
	var camera_global_position : Vector2
	if get_viewport().get_camera_2d() != null:
		camera_global_position = get_viewport().get_camera_2d().global_position

	if enable_debug:
		var debug_text = str(camera_global_position)
		debug_text = debug_text + "\n" + "Game Paused: " + str(game_state.pause_state) + "("+str(get_tree().paused)+")"
		debug_text = debug_text + "\n" + "Level loading: " + str(world_state.is_level_loading)
		debug_text = debug_text + "\n" + "time: " + str(game_state.game_time)
		debug_text = debug_text + "\n" + "day percent: " +  String.num(fmod(game_state.game_time/game_state.time_in_day,1.0)*100,2)
		#TODO: If need, then have the game hander expose it or the player state
		#debug_text = debug_text + "\n" + "player input: " + str(!Player.paused)
			#NOTE: this need to change with the new item system. was added with the old to get it working
		#NOTE: may need player or game connect these to signal instead of a direct ref
		var players:Array[Node] = get_tree().get_nodes_in_group("Player_Pawns")
		if players.size() > 0:
			var player_inventory = players[0].inventory.inventory
		#if Player.state != null and Player.pawn != null:
			#TODO: have an inventory assign here or grab from state/data
			#since acess to a pawn my be removed
			#var player_old_inventory = Player.state.fetch("inventory", "pawn")
			#var player_inventory = Player.pawn.inventory.inventory
			
			if player_inventory != null:
				debug_text = debug_text + "\n" + "Inventory:"
				for item in player_inventory:
					#debug_text = debug_text + "\n" + str(item)
					var item_type = item.get_type()
					if item_type == null:
						continue
					debug_text = (
						debug_text + "\n" + 
						str(item.get_meta("unique_name",str(item_type.display_name))) +
							"("+str(item_type.display_name)+"):" + 
						str(item.amount)
						)
		debug.text = debug_text
