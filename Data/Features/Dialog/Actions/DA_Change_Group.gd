class_name DA_Change_Group extends Dialog_Action

##the id of the new group to use
@export var new_group : String
#Note: if above is null in data, the other options should be treated as false

##This will use the default group instead of new_group. If true this will ignore new_group value
@export var reset_to_default : bool = false

#NOTE: save locally is diffrent. probably keep it on data so it can toggle the state to reset or not per session
##store the new group in the handler state so it persist between reloads
@export var save_change: bool = true

##if at the end of a group, this will continue as if new new group extends from this
@export var continue_to_group: bool = false

func run(dialog_data : Dialog_Data):
	var group = new_group
	if reset_to_default: group = "default"
	if dialog_data != null: 
		dialog_data.change_group(group,save_change,continue_to_group)
	
	#TODO: save the change or have a function in dialog_data for setting group with a save parameter
