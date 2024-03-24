class_name Old_Man_Interact_Data extends Interactive_Data

#THIS appears to work. just need a class name and make sure everything is link correctly
#but may be a bit before changing the old man character 

@export var dialog_data : Dialog_Data = load("uid://eceb7uvicyqu")

#todo: the event pass eould have a few ofthis data. also should not store event in a class level var since it ment gc after all tasks are finished
func interact(handler, instigator, interactee, data):
	if dialog_data.state != 0:
		return
	if dialog_data.visited:
		#var player_vars = handler.state.metadata
		var total_rare_fish_caught = handler.state.fetch("total_rare_fish_caught")
		if total_rare_fish_caught == null : total_rare_fish_caught = 0
		if total_rare_fish_caught == 2 :
			if randi() % 10 > 3:
				dialog_data.topic = "rare1"
			else:
				dialog_data.topic = ""
		elif total_rare_fish_caught > 2:
			if randi() % 10 > 3:
				dialog_data.topic = "rare2"
			else:
				dialog_data.topic = ""
		
		#print("testing the new system")
		#now can decide when to load dialig as well as get notify when it would have started
	#below probably should be a static function in an event libaray since
	#the path go through so many nodes(well two, but still)
	#handler.get_hud().gui_dialog.start_dialog(target, dialog_data)
	
	#will start the dialog logic
	dialog_data.start_dialog(interactee,instigator,handler)
	#will open the dialog window.#TODO: maybe it is best to call it
	#due to interaction being more of a connector? 
	Game.start_dialog(dialog_data)
