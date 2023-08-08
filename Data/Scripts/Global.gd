extends Node

#will have generic getters in global
func get_player_handler(index = 0):
	return get_node("/root/GameHandler/PlayerHandler"+str(index))
	
func get_game_handler(): 
	return get_node("/root/GameHandler")
	
func get_world_handler(): 
	return get_node("/root/GameHandler/WorldHandler")
	
func get_hud(): 
	return get_node("/root/GameHandler/HUD")
	
func get_player_handler_from_pawn(pawn): 
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

func is_client_player(source): #either player handler or pawn
	var player_handler = get_player_handler(0)
	if player_handler == source:
		return true
	if player_handler.pawn == source:
		return true
	return false


