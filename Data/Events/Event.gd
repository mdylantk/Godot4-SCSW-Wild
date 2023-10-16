class_name Event extends Resource
#this class hold data related to an event as well as shared getter/setters and fuctions

#TODO: will not listen since this may become a static class
#event will be signals that pass data. this data would have a cancel option and should
#be a pass by ref type. after listeners are call, it will preform task unless canceled
#parameters in signales can be overriden if stat have it as a key.
#event instead will trigger signal a train recated to that object and listerners
#can react with, or if vaild data is pass, cancel or change the outcome
signal event_finished(event)

#function to call to check data. better to use if caller did not pass the data
static func is_canceled(data) -> bool:
	if data != null:
		if data.has["canceled"]:
			if data is Dictionary:
				return data["canceled"]
			else:
				return true
	return false
	
static func cancel_event(data):
	if data != null:
		if data is Dictionary:
			data["canceled"] = true
		elif data is Array:
			data.append("canceled")
		#need to do a case for Tuple maybe


#a flag that ment to stop modifcation after proccing state finishes. mostly a failsafe.
var is_active : bool = true
#when the event is proccess, this will stop the logic if false
var canceled : bool = false
#the one calling or exicuting the event. aka self or in network case this could be the controller
var owner
#the one who 'cause' the action...if event have a causer. Note: could be an array in some cases
var instigator
#the one the event effect if the event have a target. Note: could be an array in some cases
var target 
#this allow the event handler to know what listener to call beside the event listern
var type

#todo: maybe add a abstract state. the idea is that listerner might be able to async while
#untill is_active = false, is_canceled = true, or the state is the level it is allowed to edit the 
#code at. also could just loop the listern.emit to a max state, and just increast state to max 
#or reduce to 0. note this just for editing order so if 99% of the time only one thing edit it, then it not needed 

#this is a placeholder. may be kept so data stored can be similar
var meta : Dictionary 

func _init(event_owner=null,event_type="Event",event_instigator=null,event_target=null, event_meta = {}):
	owner = event_owner
	type = event_type
	instigator = event_instigator
	target = event_target
	meta = event_meta

#property is the meta, but as func they could be used to trigger logic or set/get non meta properties
func set_property(property_name, property_value):
	meta[property_name] = property_value
	
#return null so a null check can be used.
func get_property(property_name):
	if meta.has(property_name):
		return meta[property_name]
	else:
		return null
		
func end_event(cancel : bool = false):
	canceled = cancel
	is_active = false
	event_finished.emit(self)

static func test():
	#Note: could have the logic for reg event as static.
	#but since signals are related, it be best for the game handler to process it
	pass
