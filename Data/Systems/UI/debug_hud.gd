extends CanvasLayer

@export var enable_debug : bool = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var debug := %Debug
	var camera_global_position : Vector2
	if get_viewport().get_camera_2d() != null:
		camera_global_position = get_viewport().get_camera_2d().global_position

	if enable_debug:
		var debug_text = str(camera_global_position)
		debug_text = debug_text + "\n" + "Game Paused: " + str(Game._pause_state) + "("+str(get_tree().paused)+")"
		debug_text = debug_text + "\n" + "Level loading: " + str(World.level_loading)
		debug_text = debug_text + "\n" + "player input: " + str(!Player.paused)
			#NOTE: this need to change with the new item system. was added with the old to get it working
		#NOTE: may need player or game connect these to signal instead of a direct ref
		if Player.state != null:
			#var player_old_inventory = Player.state.fetch("inventory", "pawn")
			var player_inventory = Player.pawn.inventory.inventory

#			if player_old_inventory != null:
#				debug_text = debug_text + "\n" + "Old Inventory:"
#				for item in player_old_inventory:
#					debug_text = debug_text + "\n" + str(item["meta"]["name"]) + ":"+ str(item["amount"])
			#this will display new inventory items when the system is added.
			#the source currently from the pawn inventory instead of player state
			#(since saving is the last part if adding it)
			if player_inventory != null:
				debug_text = debug_text + "\n" + "Inventory:"
				for item in player_inventory:
					#debug_text = debug_text + "\n" + str(item)
					debug_text = (
						debug_text + "\n" + 
						str(item.get_meta("unique_name",str(item.type.display_name))) +
							"("+str(item.type.display_name)+"):" + 
						str(item.amount)
						)
		debug.text = debug_text
