class_name Generic_Event extends Resource
#this class hold data related to an event as well as shared getter/setters and fuctions

signal event_finished(event)

#the flow of event is that it get pass to game handler (to regester it)
#this would trigger listerner to event_update that pass the new event
#multi step events could be pass to allow diffrent access levels if needed(but probably for moding)
#after the next tic/update, it will process the event unless the event is delayed
#the one that create the event will process it so the delay may need to happen there
#also the delay could cause issue may need to test to see what run after reg event
#may need a prossing flag or three states or just 2-3 logic exicutions. int, process, end
#reg(init), listen.emit(aka processing), end(exicution)

#Note: do not really need listerners. could just reg in game handler or a event bus
#and call a method to the reg. may be able to do it with groups, but not sure if that be slower
#may mix systems since it may not be best to store ref unless there a way to listen on clear
#but waht about group. entity group call would let all entity know a event pass, the issue
#is that it need the func delare and any can passivly subscribe to it
#so it more like is it a broadcast event or an event between two object that the
#server listen into (note the main goal is to have other handler do things when an event fires
#without having all the handler listen to the objects signals. object->game || handlers
#an issue is that the handler may want to know if it pass so maybe a start and end signal is needed
#group call would be too vague for this case since only the handle would want to know
#also game could just call the signal in the other handlers

#what if event call it signal, listen to it then emit it from the correct handler, then state it finished 

#NOTE: all the property could be added to meta, but it should be easier to set like this

#a flag that ment to stop modifcation after proccing state finishes. mostly a failsafe.
var is_active : bool = true
#when the event is proccess, this will stop the logic if false
var is_canceled : bool = false
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
	is_canceled = cancel
	is_active = false
	event_finished.emit(self)

static func test():
	#Note: could have the logic for reg event as static.
	#but since signals are related, it be best for the game handler to process it
	pass
