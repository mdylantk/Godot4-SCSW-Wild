extends CharacterBody2D

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
