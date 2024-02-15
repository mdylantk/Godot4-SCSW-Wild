extends CharacterBody2D

@export var dialog_data : Dialog_Data

#NOTE: it seem the catching of fish mess up into. need to make sure that intro flag is check properly(goingh to try to add it)
#also need to make sure it runs only on 0 so long messages do not get canceled

func _ready():
	#if Game.get_player_handler() != null:
	#	var player_data = Game.get_player_handler().state.metadata #SINCE gui is client side, only need to worry about player 1
	#	var dialog = get_meta("Dialog")
	#	if player_data.has("visited_"+str(dialog.id)) && dialog.save_visited_flag :
	#		dialog.visited = player_data["visited_"+str(dialog.id)]
	pass
		
func on_interact(handler, instigator, target, data):#_target):
	#if true:#Global.is_client_player(instigator):
	var player_vars = handler.state.metadata
	
	if player_vars.has("visited_"+str(dialog_data.id)) && dialog_data.save_visited_flag :
		dialog_data.visited = player_vars["visited_"+str(dialog_data.id)]
	
	if dialog_data.state != 0:
		return
	if dialog_data.visited:
		if player_vars["total_rare_fish_caught"] == 2 :
			if randi() % 10 > 3:
				dialog_data.topic = "rare1"
			else:
				dialog_data.topic = ""
		elif player_vars["total_rare_fish_caught"] > 2:
			if randi() % 10 > 3:
				dialog_data.topic = "rare2"
			else:
				dialog_data.topic = ""
		
		#print("testing the new system")
		#now can decide when to load dialig as well as get notify when it would have started
	handler.get_hud().gui_dialog.start_dialog(self, dialog_data)
	pass
