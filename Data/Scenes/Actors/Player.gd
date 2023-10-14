extends CharacterMovement

@onready var inventory = $Inventory


func _process(_delta):
	#update the spite to indicate hit direction
	$Direction.position = facing_dirction*12

#var test_index = 0
##func _input(event) :

#	if event.is_action("Accept") && event.is_action_pressed("Accept"):		
#		var space_state = get_world_2d().direct_space_state #can get a lot just with the player
		# use global coordinates, not local to node
#		var query = PhysicsRayQueryParameters2D.create(
#			global_position, 
#			global_position+(facing_dirction*24),
#			0b10000000_00000000_00000000_00000001, #last is 1, first is 32
#			[self])
#		#0b10000000_00000000_00000000_00001101
		#query.exclude = [local_player]
#		var result = space_state.intersect_ray(query)
#		if "collider" in result:
#			if result["collider"] is TileMap :
				#below test for tilemap data. keeping for now so it be easier to
				#set up a tile base interaction system like search/forage/look/chop
				#print(result["rid"])
				#print(result["collider"].get_coords_for_body_rid(result["rid"]))
				#print(result["collider"].get_layer_for_body_rid(result["rid"]))
				#print(result["collider"].get_cell_tile_data(
				#	result["collider"].get_layer_for_body_rid(result["rid"]),
				#	result["collider"].get_coords_for_body_rid(result["rid"])
				#))
#				pass
#			else:
#				if result["collider"].has_method("on_interact"):
#					result["collider"].on_interact(self)
