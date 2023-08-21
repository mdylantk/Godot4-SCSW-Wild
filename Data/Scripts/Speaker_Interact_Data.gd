class_name Speaker_Interact_Data extends Interactive_Data

@export var dialog_data : Dialog_Data

#could have listerners and state here
#currently this is not used and if so it be for
#generic ncp chat untill more is added

func interact(_instigator,_owner,_data = null):
	if Global.is_client_player(_instigator):
		Global.get_hud().gui_dialog.start_dialog(_owner, dialog_data)
	
	super.interact(_instigator,_owner,_data)
