class_name Speaker_Interact_Data extends Interactive_Data

@export var dialog_data : Dialog_Data

#could have listerners and state here
#currently this is not used and if so it be for
#generic ncp chat untill more is added

func interact(handler, instigator, target, data):
	if handler != null:
		#handler.get_hud().gui_dialog.start_dialog(handler, dialog_data)
		General_Events.start_dialog(handler, handler, dialog_data)
	
	super.interact(handler, instigator, target, data)