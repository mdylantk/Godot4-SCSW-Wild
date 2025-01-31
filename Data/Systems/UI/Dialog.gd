class_name Dialog_Handler extends CanvasLayer
signal started()
signal ended(canceled)

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
var action_data : Action_Data

var is_cancelable:bool = true


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
		start()

func update_page_text(index:int = 0,end_dialog:bool = false):
	#todo: if typewrite effect is used, forwarding (probably happen before this is calles)
	#should display all text first
	if index < split_text.size() and index >= 0:
		$Text.text = split_text[index].format(data)
		print_debug(index)
		page_index = index
	elif !end_dialog:
		print_debug("is at dialog end, but action disallow dialog to end")
		return
	elif index < 0 and is_cancelable:
		print_debug("start")
		#note: will disable dialog. action can restart it afterwards
		#NOTE: may need a flag to diable this so some dialogs can not be canceled
		#but only finished. an action could do that as well. all it dose is keep this viable
		cancel()
		#NOTE: is_cancelable will disable cancel action
		#mostly to prevent it from repeating. if a action is needed
		#then faking the canel blocking via action be ideal
		
	elif index >= split_text.size():
		print_debug("end")
		finish()
		
	else:
		print_debug("this probably being called since the dialog can not be canceled")

func start(index:int = 0):
	UI.enable_player_input = false
	update_page_text(index)
	visible = true

func cancel():
	print_debug("cancel")
	UI.enable_player_input = true
	visible = false
	ended.emit(true)
	if cancel_action != null:
		cancel_action.run(action_data)
	
func finish():
	UI.enable_player_input = true
	print_debug("finished")
	visible = false
	ended.emit(false)
	if accept_action != null:
		accept_action.run(action_data)



func _process(_delta):
	#may need to have this on a timer that can be pasued
	#also may be best to pause movement instead of waiting for change
	#NOTE: dedicate keys to forward or reverse text. cancel to cancel and accept as a second forward
	#as well as not a forward when an input request is active
	if visible:
		if data.has("target"):
			var target_pos:Vector2 = data["target"].global_position
			var source_pos:Vector2 
			if data.has("source"):
				source_pos = data["source"].global_position
			else:
				source_pos = get_viewport().get_camera_2d().global_position
			#var camera_global_position = get_viewport().get_camera_2d().global_position
			if (source_pos - target_pos).length() > 256:
				print_debug("canceled by distance")
				cancel()
				
		
func _input(event: InputEvent) -> void:
	if !visible : return
	if event.is_action_pressed("Right"):
		update_page_text(page_index+1)
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("Left"):
		update_page_text(page_index-1)
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("Accept"):
		update_page_text(page_index+1,true)
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("Cancel"):
		cancel()
		get_viewport().set_input_as_handled()

#func update_text():
#	if dialog_data != null:

#		var dialog_text = dialog_data.get_text(dialog_index)
#		if dialog_text == null:
#			dialog_index = 0
#			end_dialog()
#		else:
#	
#			dialog_index += 1
#			$Text.text = dialog_text
#			visible = true
