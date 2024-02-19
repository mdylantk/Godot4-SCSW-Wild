extends CanvasLayer

#TODO: target and such is stored in the dialog data. 
#may need to verify the speaker is speaking to the correct player in the future
#so may need to pass the pawn or handler who owns this
var target = null
var cooldown_timer : float = 0
var dialog_index = 0
var dialog_data : Dialog_Data

#todo: probably add signals to this or data so that func may not need to be call or var watched

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

func end_dialog():
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
			#return
			
		if Input.is_action_just_pressed("Accept") :
			update_text()
			
			pass
			#cycle text or end it if at end
		if Input.is_action_just_pressed("Cancel") :
				#cancle the text. ideally not flagging intro read
			end_dialog()
	#note: may need to listen to player input(or for now untill a player hud/control is set up) and maybe only listen to it here

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
