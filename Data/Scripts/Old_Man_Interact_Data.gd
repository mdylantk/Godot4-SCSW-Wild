class_name Old_Man_Interact_Data extends Interactive_Data

#THIS appears to work. just need a class name and make sure everything is link correctly
#but may be a bit before changing the old man character 

@export var dialog_data : Dialog_Data

func interact(_instigator,_owner,_data = null):
	if Global.is_client_player(_instigator):
		if dialog_data.state != 0:
			return
		if dialog_data.visited:
			var player_vars = Global.get_player_handler().player_state.metadata
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
		Global.get_hud().gui_dialog.start_dialog(_owner, dialog_data)
	pass
