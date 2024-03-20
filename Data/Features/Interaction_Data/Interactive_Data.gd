class_name Interactive_Data extends Resource
signal finished(canceled : bool, data : Dictionary)
#this is the base class for anything interative. 
#it should hold place holder functions and 
#data that may display on interact. the children will have most of the 
#unquie data and such.

#NOTE: Local to scene is needed else reource is shared

func interact(handler, instigator, interactee, data):
	#event.set_property("interactive_data",self)
	print_debug(str(instigator) + "interact with" +str(interactee))
	finished.emit(true,{})
	#NOTE: connected need to disconnect itself
	#_owner will be who owns this. since the owner will be linking it, then it cna pass it self
	#_data is a placeholder for any extra data for now
