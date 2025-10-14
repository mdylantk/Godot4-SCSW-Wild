#the point of this is to reduce the need of global and sceen tree acess
#the base will have basic send and recive call, but dedicated children
#is ideal to simpify calls
class_name Base_Events extends Resource

#NOTE: event signal is not expected to be called in children
#it could, but not nessary. these are for protoyping or for abstract systems
#Though later groups be better for it

#listernes connect to the event
signal event(id:String, data:Variant)

#handler or triggers call the event
func call_event(id:String, data:Variant):
	event.emit(id, data)
