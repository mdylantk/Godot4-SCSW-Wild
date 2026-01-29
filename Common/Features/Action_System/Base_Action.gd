class_name Base_Action extends Resource

#NOTE: Actions are meant to be read only. Action data is the 
#instance state of the action while actions contains the editor set
#values. (this is not set in stone. New actions could be created at
#run time, but this is design to help add logic to nodes).
#NOTE: Actions should return true unless it is force to be canceled
#or if it need a fail case. This is more a future prediction that an action
#fail may cause a sequence of actions to end or just to check to see if action
#was sucessful.
#NOTE: the return bool could be for cases that did not go well or failed instead
#of being canceled cases. canceled cases can be handle in the data
#TODO: deicide and make sure false is return (probably return true of handled
#and false means something went wrong and action ran did not do anything)

func run(data:Action_State) -> bool:
	#NOTE: action is likly to fail if action state is null
	#but some action do not make use of an action state
	#TODO: decide how to handle if action pass is null
	#chain action would need a proper state, so having one with
	#null values may be ideal (but could still break)
	if data:
		#NOTE: action state probably should not know about it action?
		#keeping this here, but may default to having action unknown
		#and let extended actions decided if they need theirselves stored
		#(also chain actions would work better if they store the starting action
		#and the progress state or the current action...if needed. such cases
		#may not be needed)
		data.action = self
	return _run(data)

func _run(data:Action_State) -> bool:
	return true
	
