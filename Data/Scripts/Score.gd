extends CanvasLayer

@onready var score_text = $ScoreText

#var data_source
var score_data : Dictionary = {}

#todo: have this display data and an option to 'fade out' after some time
#could even use a parent script that share a generic set data or use the metadata
#but the function call would allowe it to display or hide itself
#the issue is dynamic data linking. I wonder if there a way to pass by ref
#seems dict and array are suppose to pass by ref, just would need key/index array
#but the issue is allowing other cases, naming formats, and such
#the score gui probably not the best to start with 

#also could use signals, but that means all updates need to have a function call that could
#trigger signal

func update_data(data :Dictionary = {}) :
	score_data = data
	if data.is_empty():
		visible = false
		#hide
	else:
		var new_text = "[center]"
		for score_name in score_data:
			new_text += str(score_name) + ": " + str(score_data[score_name]) +"\n"
		score_text.text = new_text
		visible = true
		#change and make visible

#func update_text(common = 0, rare = 0):
#	score_text.text = "[center]Common: " + str(common) + " Rare: " + str(rare)
#should have a function that handles changing images

#func _process(_delta):
	#if data_source == null: #gui should handle when things are display or set. 
	#	data_source = Global.get_player_handler().player_state.metadata
	

	#if data_source != null:
	#	data_source = data_source.player_state.metadata
	#else:
	#	data_source = Global.global_varibles
	
	#if data_source["total_common_fish_caught"] <= 0 and data_source["total_rare_fish_caught"] <= 0:
	#	update_data()
		#clearing data to hide it
		#but should be handle diffrently. probably gui handles
		#this tick should not be here with new system, but here untill the new system
		#add an on_update system for changes
	#else:
	#	update_data({"Common":data_source["total_common_fish_caught"],"Rare":data_source["total_rare_fish_caught"]})
	#	if !visible:
	#		visible = true
	#	update_text(data_source["total_common_fish_caught"], data_source["total_rare_fish_caught"])
		
