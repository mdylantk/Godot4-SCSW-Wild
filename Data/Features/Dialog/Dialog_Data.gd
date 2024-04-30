class_name Dialog_Data extends Resource

#NOTE and TODO: new system is signal base, but the question is should this be unquie for 
#each ncp that talks or should it be on the player and additial logic added to it
#the issue is malking sure the connection is properly reseted on all parties
#it may be easier to load the dialog in her and have it player owned with the state
#refreshing with each end or vaild start. also means the dialog interaction can
#keep track of the init visited bool and logic source
#NOTE:
#New system should be own by the player handler and connected to the gui. 
#inbtreaction data can hold other data as well as dialog sources and logic
signal start
signal end

#when the logic is added, this will let listerners there a change in the text
signal text_update
#but for the gui

#TODO: should link static dialog resources or files to this
#and use this as the dialog state
#NOTE: the dialog resource should return an array. this would
#allow it to have additinal functionality. also allow it to pull
#from external sources if needed.

@export var id : String = "generic_dialog"
@export var defalut_name : String = "generic_name":
	set(value):
		name = value
var name : String
@export var defalut_icon : Texture2D:
	set(value):
		icon = value
var icon : Texture2D
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

##the starting group name.
@export var init_group_name : String = "intro":
	set(value):
		group_name = value
#this is the id used as a backup. could reserve the keyword "default"
#NOTE: will use the keyword default for main dialog path
#@export var default_group_name : String = "default"
@export var default_text_groups : Array[Dialog_Group]:
	#will not store. if this becomes a tool, then this need to store default text group
	#else editing be hard
	set(value):
		for group:Dialog_Group in value:
			print_debug(group)
			if group != null:
				if text_groups.has(group.group_name):
					print_debug("group exists, overwriting it.")
				text_groups[group.group_name] = group
		print_debug(text_groups)
var text_groups : Dictionary
var group_name : String
#PROBABLY should make get text only get text and add a function to forward text abd return if it reach the end

func change_group(new_group:String,save:bool = true, continue_dialog:bool = false):
	if text_groups.has(new_group):
		group_name = new_group
		#TODO: save is true
		#TODO: have it continue or end base on continue_dialog
		#note: may need a better way since this will not reset the index
		#so if not at end, it will use last index 
		if continue_dialog:
			at_end = false
	pass

var text :String
var segment_index : int 
var at_end : bool = false
var action: Dialog_Action
func update_text():
	if action != null:
		action.run(self)
		action = null
	if !text_groups.has(group_name):
		print_debug("dose not have a " + group_name)
	var group:Dialog_Group = text_groups[group_name]
	var segment = group.get_segment(segment_index)
	at_end = group.is_at_end(segment_index)
	if segment.speaker_name != "":
		name = segment.speaker_name
	else:
		name = defalut_name
	if segment.speaker_icon != null:
		icon = segment.speaker_icon
	else:
		icon = defalut_icon
	text = segment.get_text()
	#TODO run the actions
	
	if segment.start_action != null:
		segment.start_action.run(self)
	action = segment.end_action
	#TODO update the index
	if at_end:
		segment_index += 1
	else:
		segment_index = 0

#this allow the data to not need to access outside sources without being assigned
#this logic may(if it run server side) or may not(if only client runs it) need to change for multiplayer
#may need to be an array to allow multi target conversation

#the gui source is found in the handler. or it can be the handler of the target if there is one
var current_handler = null
#the object this dialog belong to
var current_speaker = null
#usally the pawn of the handler. the one the speaker is talking too 
var current_target = null
#may use this to confirm a connection, else 
var current_display = null

func start_dialog(speaker, target, handler):
	if state == 0:
		current_handler = handler
		current_speaker = speaker
		current_target = target
		state = 1
		start.emit()
		#poor way to update, but this system still need to be reworked
		if current_handler.state.fetch("visited_"+str(id)) != null:
			visited = current_handler.state.fetch("visited_"+str(id))
		return true
	#should return false if failed
	return false
	
func end_dialog():
	current_handler = null
	current_speaker = null
	current_target = null
	state = 0
	end.emit()

#TODO: the new system will have the index stored and reset here
#basicly this will hold the dialog info. This also means this need a way to
#forward or backwards the text. pretty much a function that increase or decrease
#the index value. 

func get_text(index = 0): #index is ignored if default and random. also invald may be treated as 0 or return null
	#if at_end:
	#	return null
	#update_text()
	#return text
	##Note broke, but might be the dialog gui not modify to work with this
	#may build an action system sandbox to assign things
	
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
			if save_visited_flag and current_handler != null:
				#need to store the handler here
				current_handler.state.store("visited_"+str(id),true)
				#current_handler.set_player_meta("visited_"+str(id), true)
				#Global.get_player_handler().state.metadata["visited_"+str(id)] = true
	index += 1
	return text
	#return null if all fail
	#may forward index just because it be easier to track.
	
##NOTE: the is_visit var is reset when ncp is unloaded so global var is needed
#so intro play once and then the id is catch in global
#then default is used.
#if ncp have it own code or a quest logic is running, it can grab data from other text if it exist
#this here just to hold text. logic can happen elsewhere if 
