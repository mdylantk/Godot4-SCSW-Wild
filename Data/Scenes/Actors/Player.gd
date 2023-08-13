extends CharacterMovement
#signal notify() #the issue is the fish calling the notify for gui
#so i need a way to do that logic but send it here instead of connecting to some random object?

var fish_turnin = 0 #temp way to get specal messages

#func _ready():
	#Global.get_hud().loading = true #note, need to press a button to exit
	#print("player loaded")
	#Global.local_player = self
	#randomize() #need to have it int in global.
	

func _process(_delta):
	$Direction.position = facing_dirction*12
	
	#this is here since use_input is tied with the loading screen. a state system is needed in the future 
	var active_chunk = Global.get_world_handler().get_current_chunk(global_position)
	#this is a temp way to diable movement if chunk is loading. 
	if active_chunk != null:
		use_input = active_chunk.is_ready
		#Global.get_hud().loading = !active_chunk.is_ready

var test_index = 0	
func _input(event) :
	
	
	if event.is_action("Accept") && event.is_action_pressed("Accept"):
		#print(Global.get_world_handler().get_current_chunk(global_position).is_ready)
		
		#TEST
		#Global.get_world_handler().visible = !Global.get_world_handler().visible
		#Global.get_world_handler().preloaded_chunks[Vector2.ZERO].visible = !Global.get_world_handler().preloaded_chunks[Vector2.ZERO].visible 
		#TEST END
		
		var space_state = get_world_2d().direct_space_state #can get a lot just with the player
		# use global coordinates, not local to node
		var query = PhysicsRayQueryParameters2D.create(
			global_position, 
			global_position+(facing_dirction*24),
			0b10000000_00000000_00000000_00000001, #last is 1, first is 32
			[self])
		#0b10000000_00000000_00000000_00001101
		#query.exclude = [local_player]
		var result = space_state.intersect_ray(query)
		if "collider" in result:
			if result["collider"] is TileMap :
				#print(result["rid"])
				#print(result["collider"].get_coords_for_body_rid(result["rid"]))
				#print(result["collider"].get_layer_for_body_rid(result["rid"]))
				#print(result["collider"].get_cell_tile_data(
				#	result["collider"].get_layer_for_body_rid(result["rid"]),
				#	result["collider"].get_coords_for_body_rid(result["rid"])
				#))
				pass
			else:
				#print(result["collider"])
				#probably should have a componet that handles on_interacts
				#with some default options with an option for the parent to take control
				if result["collider"].has_method("on_interact"):
					result["collider"].on_interact(self)
				#if result["collider"].has_meta("Dialog") :
				#		Global.dialog.start_dialog(result["collider"])
		#else:
			#var test_array = [
			#	Vector2(0,0), 
			#	Vector2(4,8),
			#	Vector2(7,-2),
			#	Vector2(-4,5),
			#	Vector2(-9,-6),
			#	Vector2(-3,0),
			#	Vector2(0,11),
			#	Vector2(0,-21),
			#	Vector2(42,0)
			#]
			#if test_index >= test_array.size():
			#	test_index = 0
			#global_position = test_array[test_index] * (16*32)
			#use_input = false #need a proper way to force loading. noo much of a delay or depency on input
			#test_index += 1
