class_name Interactive_Data extends Resource
 
#this is the base class for anything interative. 
#it should hold place holder functions and 
#data that may display on interact. the children will have most of the 
#unquie data and such.

func interact(_instigator,_owner,_data = null):
	print(str(_instigator) + "interact with" +str(_owner))
	pass
	#_owner will be who owns this. since the owner will be linking it, then it cna pass it self
	#_data is a placeholder for any extra data for now
