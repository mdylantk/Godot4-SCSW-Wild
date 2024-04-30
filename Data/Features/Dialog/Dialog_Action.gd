class_name Dialog_Action extends Resource

##The controller that init the chain of actions
#var handler:Node = null
##The object that represent the triggering(aka the player pawn)
#var source:Node = null
##the object that being interacted with
#var target:Node = null

##Todo: need the dialog handler ref with a way to identify this source
#var dialog_data : Dialog_Data

##extra data that may be pass for other cases
#var data:Dictionary = {}
	
#could pass the dialog data here. should have a ref to the target and other data
func run(dialog_data : Dialog_Data):
	pass

#NOTE: default(built in) action for no action(that override dialog_data settings)
#is to display the text untill a input is press, the source become null or too far away
#it will cycle non-random segments untill the end is reached with each input for forwarding

