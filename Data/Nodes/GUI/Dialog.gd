extends CanvasLayer

#TODO: target and such is stored in the dialog data. 
#may need to verify the speaker is speaking to the correct player in the future
#so may need to pass the pawn or handler who owns this
var target = null
var cooldown_timer : float = 0
var dialog_index = 0
var dialog_data : Dialog_Data

##action to run if about to end dialog
var cancel_action : Base_Action
##acttion to run if about to finish dialog
var accept_action : Base_Action

##handles the text in parts since the display only can fit so much
var split_text : PackedStringArray
var page_index : int = 0

##the data used for the actions. this is shared since it should be a ref of a state
##also chain action may need to be careful of reusing the same data.
var data := {}

var is_cancelable:bool = true

#NOTE TODO: should work on rrwriting this to handles displaying text
#and assiment of action to buttons

#START new
#this are simple setters. can be expended on as needed
#should also have a refresh which may just change visability of stuff
#and probably should null it just incase

#this is meant to change speaker data independent of setting text so it
#only need to be called when the speaker changes
func setup_speaker(display_name:String = "", icon:Texture2D = null):
	$Name.text = "[center]"+display_name
	$Icon.texture = icon

func setup_text(
		text:String, accept:Base_Action = null, cancel:Base_Action = null,
		start_dialog:bool = true, cancelable: bool = true
	):
	split_text = text.split("/p")
	accept_action = accept
	cancel_action = cancel
	
	is_cancelable=cancelable
	
	if start_dialog:
		#this will trigger the dialog so a seprate action wont need to start it
		#only apply if dialog not started.
		#Note: could have gui or UI handle it, or signal up and have the action
		#call these
		update_page_text(0)
		visible = true

func update_page_text(index:int = 0):
	#todo: if typewrite effect is used, forwarding (probably happen before this is calles)
	#should display all text first
	if index < split_text.size() and index >= 0:
		$Text.text = split_text[index].format(data)
		print_debug(index)
		page_index = index
	elif index < 0 and is_cancelable:
		print_debug("start")
		#note: will disable dialog. action can restart it afterwards
		#NOTE: may need a flag to diable this so some dialogs can not be canceled
		#but only finished. an action could do that as well. all it dose is keep this viable
		visible = false
		if cancel_action != null:
			cancel_action.run()
		#NOTE: is_cancelable will disable cancel action
		#mostly to prevent it from repeating. if a action is needed
		#then faking the canel blocking via action be ideal
		
	elif index >= split_text.size():
		print_debug("end")
		visible = false
		if accept_action != null:
			accept_action.run()
		
	else:
		print_debug("this probably being called since the dialog can not be canceled")


#END new

func start_dialog(new_target, new_data) :
	#targer is needed to know if player get too far form it.
	#could also be a point, but an object allow more option
	#but could hold it in the dialog_data...but having owner ref there seem redundent 
	if new_target != null :
		target = new_target
		if new_data is Dialog_Data:
			dialog_data = new_data
		elif target.has_meta("Dialog"):
			dialog_data = target.get_meta("Dialog")
		
		if dialog_data != null :
			$Name.text = "[center]"+dialog_data.name
			$Icon.texture = dialog_data.icon
			dialog_data.state = 1 #need a way to let owner od dialog know it is cycling through text. this is one possbility
			#update_text() process seem to run after this, may need to use signal and timers instead of processes
			set_process(true)
			
func open_dialog(new_data:Dialog_Data) :
	dialog_data = new_data
	if dialog_data != null :
		$Name.text = "[center]"+dialog_data.name
		$Icon.texture = dialog_data.icon
		#dialog_data.state = 1 #need a way to let owner od dialog know it is cycling through text. this is one possbility
		#update_text() process seem to run after this, may need to use signal and timers instead of processes
		set_process(true)
		dialog_data.end.connect(close_dialog)
		update_text()
		visible = true

func close_dialog():
	visible = false
	set_process(false)
	dialog_index = 0
	dialog_data.end.disconnect(close_dialog)
	dialog_data = null

func end_dialog():
	if dialog_data != null:
		dialog_data.end_dialog()
		#if dialog_data.state == 0:
			#NOTE: end_dialog is not being called from dialog_data.
			#close_dialog()
			#pass
	return
	visible = false
	target = null
	#Todo: decide if dialog should clear it state of target and handler.
	#clearing speaker is optional since usally speaker is the owner of the dialog data
	if dialog_data != null :
		dialog_data.state = 0
	dialog_data = null
	set_process(false)
	dialog_index = 0

func _process(_delta):
	#may need to have this on a timer that can be pasued
	
	if dialog_data == null:
		#NOTE: this is a fail safe and was not needed. just here incase the system changes
		end_dialog() 
		return
		
	#Note: there may be a case where there is no speaker. this case the logic
	#should allow dialog to continue, but need to freeze player or have a timer
	if dialog_data.current_speaker == null or dialog_data.current_handler == null:
		end_dialog() 
		#return
		#if visible :
		#	visible = false
		#set_process(false)

	else:
		#todo: try to catch these or have them set in the data
			#NOTE: leaving the area while talking will break this.
			#so added the check for player. may need a function when acessing pawn to compress this issue
			#ideally in a static function or in the player handler(this is ideal since it is acessable)
			#but target can not be null either. so a check is needed either way unless this is remotly reset
		if (dialog_data.current_handler.pawn.global_position - dialog_data.current_speaker.global_position).length() > 64 :
			end_dialog()

func _input(event: InputEvent) -> void:
	#NOTE visability check fails. not really needed, but system need to be
	#reanyalzed to rebuild to work with godot better
	#NOTE: need a system to pause game related gui when in menu
	#could have it pause with the game, but maybe it want to pause the game
	#so just need to extend the system(but locally(by handler handles children input)
	if dialog_data != null:
		if event.is_action_pressed("Accept"):
			update_text()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("Cancel"):
			end_dialog()
			get_viewport().set_input_as_handled()
	#NOTE: new system needs to check of at an end of text
	#and if so, run action of exist or finish the dialog
		
		
	if event.is_action_pressed("Accept"):
		if visible:
			update_page_text(page_index+1)
			get_viewport().set_input_as_handled()
	if event.is_action_pressed("Cancel"):
		if visible:
			update_page_text(page_index-1)
			get_viewport().set_input_as_handled()

func update_text():
	if dialog_data != null:

		var dialog_text = dialog_data.get_text(dialog_index)
		if dialog_text == null:
			dialog_index = 0
			end_dialog()
		else:
	
			dialog_index += 1
			$Text.text = dialog_text
			visible = true
