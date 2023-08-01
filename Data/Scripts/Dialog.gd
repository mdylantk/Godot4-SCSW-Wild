extends CanvasLayer

var target = null
var cooldown_timer : float = 0
var dialog_index = 0
var dialog_data #note: this may make it so data can not be swap out when being used. should not be an issue in the current state

#pretty much just need to have states/flags
#as well as an id probably in the dialog so things can be temp stored
#state pretty much state if it procing or being cleared. basiscy switchs that may change the logic 
#from the normal cont. to end of topic.
#should be check each major step since it the fail switch as well
#or if a typic is change, the state should change to state a topic change
#could be bitflags stating conditions that change. 
#basicly this just display base on the state of the dialog data
#and may modify it so that the object know the state
#basicly gui should have more write power over index and object have more write power over everything else
#the data probably should have set and modify functions
#then the gui just read and listen to it
#probably could listen for change if that an option for resorces.
#or could make a binding even, but not sure how without knowing about the gui
#i mean the gui can be easly found, but may cause a two way Dependency 

func _ready():
	Global.dialog = self

func start_dialog(new_target) :
	if new_target != null :
		target = new_target
		if target.has_meta("Dialog"):
			dialog_data = target.get_meta("Dialog")
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
	#elif !visible:
	#	if target.has_meta("Dialog"):
	#		dialog_data = target.get_meta("Dialog")
	#		$Name.text = dialog_data.name
	#		$Icon.texture = dialog_data.icon
	#		update_text()
	#		visible = true
	else:
		if (Global.local_player.global_position - target.global_position).length() > 64 :
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
