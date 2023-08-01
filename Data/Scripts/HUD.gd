extends CanvasLayer

#may not be the best, but exposing these so they can be called directly instead of having to look them up
#should only be for more static gui types
@onready var gui_notify = $Notify
@onready var gui_score = $Score
@onready var gui_dialog = $Dialog

#NOTE: signals general is parent to children.
#BUT that to communicate back up
#so still not sure. stills seem useful only to listen to children or non static relationships

#this handles most of the logic for GUI and input.
#its main porpous is to manage all the gui elements as well as when to listen to input
#all other gui should be simple and indepent of it's tasks and this will thell them when to 
#run and what infomation to display (direct or by object ref and other parameters)

#may have an input listener here. game handler or player hander could have a flag to state which is 
#is listen for first

func _process(_delta):
	var player_data = Global.get_player_handler().player_state
	#may need a dict for score in playerstate or a function that can fetch it
	if player_data.metadata["total_common_fish_caught"] <= 0 and player_data.metadata["total_rare_fish_caught"] <= 0:
		$Score.update_data()
	else:
		$Score.update_data({"Common":player_data.metadata["total_common_fish_caught"],"Rare":player_data.metadata["total_rare_fish_caught"]})
	#the hud may or may not update gui elements. 
	#for less dynamic system, this be easier to handle updates and stuff
	#but if gui format have to change in various ways, it may be better to have childrent
	#update themselves. also depends on how may are updated and how pasuing works
	#pass

