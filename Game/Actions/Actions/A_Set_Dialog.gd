class_name A_Set_Dialog extends Base_Action

@export var speaker_name : String
@export var speaker_icon : Texture2D

@export_multiline var text : String
@export var accept_action: Base_Action
@export var cancel_action: Base_Action

@export var cancelable: bool = true

#@export var ui_state : UI_State = load('uid://dkc6l4f8ve4t5')
@export var dialog_state : Dialog_State = load('uid://ckldc286fg63p')

#NOTE: if data is used to format text, large data could be an issue
#if the system is used correctly, then the data should be small, else
#the data need to be manage like having an action that delete keys
#or keys that consider importaint
#ALSO may need this or a child of this that grab additinal data from
#target/source for use with data since nested types would not work well
#with the current system and it be easier to pass the data in the format call

func _run(action_state:Action_State) -> bool:
	var dialog_data : Dictionary
	if action_state:
		dialog_data = action_state.get_data("dialog_data",{})
	#NOTE: old(well current) dialog uses data, but also run actions for the caller
	#could just use action data (or call it host action data) since it should also have
	#dialog data. also could have exports to decided if an action data is created
	#for this speaker. #TODO: just handler dialog directly than this round about way
	#though this way still can be useful since the focus dialog is a state that need to be
	#cancled though the actions done should be handled by the speaker via connecting 
	#to dialog signals
	dialog_state.format_data = dialog_data
	dialog_state.speaker_name = speaker_name
	dialog_state.speaker_image = speaker_icon
	dialog_state.source_text = text
	dialog_state.show_cancel = cancelable
	
	#TODO: NEED TO MAKE SURE data instance is correct
	#it should either be passed with the callable(ui or state handles it)
	#or it need to not be assign as a metadata of the action state
	#and its ref maintain here or for the lifetime of the callables/actions
	#NOTE: if not, then changes between actions wont be maintain if
	#handled by the passed data
	#TODO: decided if the data should be duplicated or not or 
	#add a flag to decide that. generally if not duplicatedm the
	#owner can keep tabs on the state changes
	if accept_action != null:
		dialog_state.accept_task = func():
			accept_action.run(action_state)
	else:
		dialog_state.accept_task = func():pass
		
	if cancel_action != null:
		dialog_state.cancel_task = func():
			cancel_action.run(action_state)
	else:
		dialog_state.cancel_task = func():pass
	
	#may be able to use callables for the action
	#so the dialog won't need to depend on the action 
	#system while not needing to expect this to manage
	#thouse states. (it could)
	
	#NOTE: maybe need a page changed signal?
	#unless that will be handled in the ui only
	#there a possibility to nest stuff in the text,
	#but it be more work and better to chain dialog actions
	#with or without modifing states
	
	#NOTE: this will start it, but 
	#the update after it will update the page
	#again. could flag it off on start
	#or see to split it and call a update
	#when the page updates
	dialog_state.start.emit()
	
	#dialog_state.update.emit()
	
	
	#ui_state.dialog.data = dialog_data
	#ui_state.dialog.action_data = data
	#ui_state.dialog.setup_speaker(speaker_name,speaker_icon)
	#ui_state.dialog.setup_text(text,accept_action, cancel_action,true,cancelable)
	#NOTE: should the data be set here? could isolate it and add a flag stating
	#on merging or overriding it. 
	#could have a set text that just do not override the data
	return super(action_state)
