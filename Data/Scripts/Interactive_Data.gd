class_name Interactive_Data extends Resource
 
#this is the base class for anything interative. 
#it should hold place holder functions and 
#data that may display on interact. the children will have most of the 
#unquie data and such.

#TODO this is the base for holding data of what happen when interacted with
#probably should not pass an event...or well should use the pass event
#to keep tract of the on going data in cases where the interaction last longer
#that a few ticks or seconds
#which current this not used for ungoing interaction. it set up a state for dialog

func interact(handler, instigator, target, data):
	#event.set_property("interactive_data",self)
	print(str(instigator) + "interact with" +str(target))
	pass
	#_owner will be who owns this. since the owner will be linking it, then it cna pass it self
	#_data is a placeholder for any extra data for now
