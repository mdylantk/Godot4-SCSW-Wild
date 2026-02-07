class_name Dialog_Handler extends Canvas_Scene

#signal started()
#signal ended(canceled)

@export var ui_state : UI_State = UI_State.get_default_instance()
@export var state : Dialog_State = Dialog_State.get_default_instance()

##action to run if about to end dialog
var cancel_action : Base_Action
##acttion to run if about to finish dialog
var accept_action : Base_Action

##handles the text in parts since the display only can fit so much
var split_text : PackedStringArray
#var page_index : int = 0

#may need to set/get from state untill sepration from ui is finished
##the data used for the actions. this is shared since it should be a ref of a state
##also chain action may need to be careful of reusing the same data.
var data : Dictionary :
	set(value):
		state.format_data
	get():
		return state.format_data
var action_data : Action_State

var is_cancelable:bool = true

#this may need to be ref elsewhere
#but might be overrided in the gui
var tts_enable: bool = true

#TODO: decided if the voices should be catch and if so handles when language changes
#TODO: see about storing the speak data in the state
#such if it is speaking, is a new speaker(and require an intro),
#or other stuff
func speak_text(
		text: String = "", 
		voice_id : int = state.tts_voice_id, 
		pitch : float=state.tts_voice_pitch):
	if !tts_enable: 
		return
	#TODO: may need a way to know if this is in focus
	#and is currently speaking something. should not stop other
	#tts sources. they should clean up themselves so it wouldn't matter
	#except making some bug easier to find.
	DisplayServer.tts_stop()
	#NOTE: needed to check visiblity else it was playing when
	#not active due to the change in the system moving most of the
	#display changes to the on_update
	#TODO: add a way to speak the speaker name and a flag to control
	#when to use this feature. also figure out the best way to combine it
	#like maybe use a diffrence voice for pure narriation?
	if text == "" || !visible: 
		return
	var voices = DisplayServer.tts_get_voices_for_language(TranslationServer.get_locale())
	if voices.size() > 0 && voice_id < voices.size():
		DisplayServer.tts_speak(text, voices[voice_id],50,pitch)

func update_page_text(index:int = 0,end_dialog:bool = false):
	#todo: if typewrite effect is used, forwarding (probably happen before this is calles)
	#should display all text first
	if index < state.text_pages.size() and index >= 0:
		state.display_text = state.text_pages[index].format(state.format_data)
		#$Text.text = state.display_text
		#speak_text($Text.text)
		print_debug(index)
		state.page_index = index
	elif !end_dialog:
		print_debug("is at dialog end, but action disallow dialog to end")
		return
	elif index < 0 and state.show_cancel:
		print_debug("start")
		#note: will disable dialog. action can restart it afterwards
		#NOTE: may need a flag to diable this so some dialogs can not be canceled
		#but only finished. an action could do that as well. all it dose is keep this viable
		cancel()
		speak_text()
		#NOTE: is_cancelable will disable cancel action
		#mostly to prevent it from repeating. if a action is needed
		#then faking the canel blocking via action be ideal
	elif index >= state.text_pages.size():
		print_debug("end")
		finish()
		speak_text()
		
	else:
		print_debug("this probably being called since the dialog can not be canceled")


func start(index:int = 0):
	ui_state.enable_player_input = false
	update_page_text(index)
	visible = true
	on_update()
	speak_text($Text.text)
	state.started.emit()

func cancel():
	print_debug("cancel")
	speak_text()
	ui_state.enable_player_input = true
	visible = false
#	ended.emit(true)
	#NOTE: there is a canceled signal in state
	#that is reserved for the button press case
	#that should be handled by the listerner
	#before checking the state that it can end
	state.ended.emit(true)
	state.cancel_task.call()
	#if cancel_action != null:
	#	cancel_action.run(action_data)
	
func finish():
	speak_text()
	ui_state.enable_player_input = true
	print_debug("finished")
	visible = false
#	ended.emit(false)
	state.ended.emit(false)
	state.accept_task.call()
	#if accept_action != null:
	#	accept_action.run(action_data)

func on_update():
	$Name.text = "[center]"+state.speaker_name
	$Icon.texture = state.speaker_image
	$Text.text = state.display_text
	
	#Note: need to handle how tts will handle the change.
	#could pass more data in update or have it treated
	#as a force change. also could not handle it and expect
	#the triggerer to handle it if it needs to be handled
	#so another signal may be needed for that

func _process(_delta):
	#NOTE: this is old and probably unused
	#the speaker or action might handle this
	#or maybe callables should be used to update itself
	#odd but a update callable that update dynamic varibles
	#or just treat format data as a callable that returns a dictionary
	#that may be better
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
		update_page_text(state.page_index+1)
		on_update()
		speak_text($Text.text)
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("Left"):
		update_page_text(state.page_index-1)
		on_update()
		speak_text($Text.text)
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("Accept"):
		update_page_text(state.page_index+1,true)
		on_update()
		speak_text($Text.text)
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("Cancel"):
		cancel()
		speak_text()
		get_viewport().set_input_as_handled()

func _ready() -> void:
	state.update.connect(on_update)
	state.start.connect(start)

	
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
