class_name Speaker_Interact_Data extends Interactive_Data

@export var dialog_data : Dialog_Data

@export var speaker_name : String = "speaker"
@export var speaker_icon : Texture2D
@export var visited : bool = false

#could have listerners and state here
#currently this is not used and if so it be for
#generic ncp chat untill more is added

func interact(handler, instigator, interactee, data):
	if handler != null:
		#handler.get_hud().gui_dialog.start_dialog(handler, dialog_data)
		Game.start_dialog(dialog_data)
	
	super.interact(handler, instigator, interactee, data)
