extends CanvasLayer

var target = null
var cooldown_timer : float = 0
var dialog_index = 0
var dialog_data 

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
			#update_text() process seem to run after this, may need to use signal and timers instead of processes
			set_process(true)

func end_dialog():
	visible = false
	target = null
	dialog_data = null
	set_process(false)
	dialog_index = 0

func _process(_delta):
	#may need to have this on a timer that can be pasued
	if target == null :
		if visible :
			visible = false
		set_process(false)

	else:
		if (Global.get_player_handler().pawn.global_position - target.global_position).length() > 64 :
			end_dialog()
			
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
