extends Node

#TODO: Game Autoload will replace this. is_client_player still need a replacement

#will have generic getters in global
func get_player_handler(index = 0):
	#WARNING: this is still in use here
	#print_debug("MEOW?")
	return get_node("/root/Game/Player_Handler"+str(index))
	
func get_game_handler():
	print_debug("MEOW?") 
	return get_node("/root/Game")
	
func get_world_handler():
	print_debug("MEOW?") 
	return get_node("/root/Game/World_Handler")

func get_instance_handler():
	print_debug("MEOW?")
	return get_node("/root/Game/InstanceHandler")
	
func get_hud():
	print_debug("MEOW?") 
	return get_node("/root/Game/Player_Handler/HUD")
	
func get_player_handler_from_pawn(pawn):
	print_debug("MEOW?") 
	var vaild_player_index = true
	var index = 0
	while vaild_player_index:
		var player_state = get_player_handler(index)
		if player_state == null:
			vaild_player_index = false
		elif player_state.pawn == pawn:
			return player_state
		index += 1
	return null

#func is_client_player(source): #either player handler or pawn
	#print_debug("MEOW?")
	#WARNING: this is still in use here
	#var player_handler = get_player_handler(0)
	#if player_handler == source:
	#	return true
	#if player_handler.pawn == source:
	#	return true
	#return false

func change_parents(child_ref, new_parent):
	print_debug("MEOW?")
	if child_ref != null && new_parent != null:
		var old_parent = child_ref.get_parent()
		if old_parent != null:
			old_parent.remove_child(child_ref)
			new_parent.add_child(child_ref)
			
		else:
			new_parent.add_child(child_ref)
		print(str(child_ref))
		print("is now child of ")
		print(child_ref.get_parent())
		print(" from : " + str(old_parent))
		return true
	return false

