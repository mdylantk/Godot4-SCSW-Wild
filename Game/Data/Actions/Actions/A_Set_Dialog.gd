class_name A_Set_Dialog extends Base_Action

@export var speaker_name : String
@export var speaker_icon : Texture2D

@export_multiline var text : String
@export var accept_action: Base_Action
@export var cancel_action: Base_Action

@export var cancelable: bool = true

#NOTE: if data is used to format text, large data could be an issue
#if the system is used correctly, then the data should be small, else
#the data need to be manage like having an action that delete keys
#or keys that consider importaint
#ALSO may need this or a child of this that grab additinal data from
#target/source for use with data since nested types would not work well
#with the current system and it be easier to pass the data in the format call

func _run(data:Action_State = null) -> bool:
	var dialog_data : Dictionary
	if data:
		dialog_data = data.get_meta("dialog_data",{})
	#NOTE: old(well current) dialog uses data, but also run actions for the caller
	#could just use action data (or call it host action data) since it should also have
	#dialog data. also could have exports to decided if an action data is created
	#for this speaker. #TODO: just handler dialog directly than this round about way
	#though this way still can be useful since the focus dialog is a state that need to be
	#cancled though the actions done should be handled by the speaker via connecting 
	#to dialog signals
	UI.gui_dialog.data = dialog_data
	UI.gui_dialog.action_data = data
	UI.gui_dialog.setup_speaker(speaker_name,speaker_icon)
	UI.gui_dialog.setup_text(text,accept_action, cancel_action,true,cancelable)
	#NOTE: should the data be set here? could isolate it and add a flag stating
	#on merging or overriding it. 
	#could have a set text that just do not override the data
	return super(data)
