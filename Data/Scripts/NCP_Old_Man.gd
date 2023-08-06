extends CharacterBody2D

@export var dialog_data : Dialog_Data

func _ready():
	var player_data = Global.get_player_handler().player_state.metadata #SINCE gui is client side, only need to worry about player 1
	var dialog = get_meta("Dialog")
	if player_data.has("visited_"+str(dialog.id)) && dialog.save_visited_flag :
		dialog.visited = player_data["visited_"+str(dialog.id)]
		
	#this works for now, but should have an interaction component
	#that dose this nativly if it have a dialog resource
	#can have children that do specialize things like chat or trade
	#then this just listen to it to do other thing outside of 
	#its power like quest base stuff
func on_interact(_target):
	#issue is knowing if this the vaild player
	#could use the global one since just need player 0 for
	if Global.is_client_player(_target):
		#testing checks. but assing the player data this way a bit odd
		#since need to know how the handler and stat look like?
		#but maybe not. 
		var player_vars = Global.get_player_handler().player_state.metadata
		#could also inject one, but better then be static entries in the othertext
		#other text in @export probably should be an array of a resourse so one do not need to remeber to folow dic of string array string
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
		
		print("testing the new system")
		#now can decide when to load dialig as well as get notify when it would have started
		Global.get_hud().gui_dialog.start_dialog(self, dialog_data)
	pass
