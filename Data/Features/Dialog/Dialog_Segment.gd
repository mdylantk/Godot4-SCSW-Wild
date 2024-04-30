class_name Dialog_Segment extends Resource

#NOTE: could have an action to set the icon or name in dialog data, but it may be easier just overriding it here
@export var speaker_icon : Texture2D
@export var speaker_name : String
@export_multiline var text: String
@export var start_action : Dialog_Action
@export var end_action : Dialog_Action

#TODO: it may be best to store things like speaker name and icon here as well
#and use the dialog data ones as a fall back if these are null
#NOTE: should also pass the speaker name, maybe icon, to the action.
#NOTE: if action is given enough data and a ref to dialog data, then this would not be needed
#but it may be best to collect data with each step so ref would not be needed


##this may or may not be used. it just to add to the data that the action may used
##so some actions can maye use of it. actions should not be ref here to prevent
##circle depencies accidents
func append_to_data(data:={}):
	if speaker_icon != null:
		data["speaker_icon"] = speaker_icon
	if speaker_name != null and speaker_name != "":
		data["speaker_name"] = speaker_name
	data["text"] = text

##this is the safe way to get the text. it allow children of this to override it
##add a passable dict so that the text could be formated, but might be best to have it more
##expose so that actions can modify it
func get_text(format_data:={}) -> String:
	return text
