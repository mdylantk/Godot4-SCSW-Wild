class_name Dialog_Data extends Resource
#need to think of signals
#but for the gui


@export var id : String = "generic_dialog"
@export var name : String = "generic_name"
@export var icon : Texture2D 
@export var default_text_is_random : bool = false #instead of having long default text, this would allow smaller text to be sampled from
@export var visited : bool = false #will bypass into if true. 
@export var save_visited_flag : bool = true #will save if the talker been visited at least once if true. this for cases when non random ncp need to speek into once(like the old man)

@export var topic : String = "" #this probably should repalce overide_id in get_text
@export var state = 0 #-1:restart, 0:not active, 1:processing, 2:topic switch
#some of the state may not be needed if this handles getting the text. it just need func to control what is 
#display better. state could be used for resting index, but that could be done with a function


#dialog base data
@export var intro_text : Array[String]
@export var default_text : Array[String]
@export var other_text : Dictionary # other topics would be stored here. key is the topic, and the values is an array of strings

#PROBABLY should make get text only get text and add a function to forward text abd return if it reach the end

func get_text(index = 0): #index is ignored if default and random. also invald may be treated as 0 or return null
	var text_source = null
	var is_intro = false
	var is_random = false #could add a keyword in topic for some other_text to be random(just need to check)
	var text = null
	
	if !topic == "" :
		if other_text.has(topic):
			text_source = other_text[topic]
	if text_source == null:
		if visited :
			is_random = default_text_is_random
			text_source = default_text
		else: 
			is_intro = true
			text_source = intro_text
	if index < 0: 
		index = 0
	if is_random:
		if default_text.size() > 0 && index <= 0:
			#random text if conditions are true
			return default_text[randi() % default_text.size()]
		else:
			#return null so that it know to close the dialog
			index = 0
			return null
	if index < text_source.size():
		#return the text at the current index
		text = text_source[index]
	else:
		index = 0 #reset index if index greater than amount
		if is_intro:
			visited = true
			if save_visited_flag :
				Global.get_player_handler().player_state.metadata["visited_"+str(id)] = true
	index += 1
	return text
	#return null if all fail
	#may forward index just because it be easier to track.
	

	
##NOTE: the is_visit var is reset when ncp is unloaded so global var is needed
#so intro play once and then the id is catch in global
#then default is used.
#if ncp have it own code or a quest logic is running, it can grab data from other text if it exist
#this here just to hold text. logic can happen elsewhere if 
