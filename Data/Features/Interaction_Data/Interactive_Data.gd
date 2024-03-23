class_name Interactive_Data extends Resource

#NOTE: signals wont resturn self or data. listerners should know where to get the data
#but the component node that relay the signal will pass the reffrence since it handling the object
#and if connecting to those signals, the other may not know how to get the data correctly
#also allow for multi interaction instance if the componenet allows it
signal started(data:Interactive_Data)
signal updated(data:Interactive_Data)
signal finished(canceled : bool,data:Interactive_Data)
#this is the base class for anything interative. 
#it should hold place holder functions and 
#data that may display on interact. the children will have most of the 
#unquie data and such.

var handler 
var interactor 
var interactee 
var data : Dictionary

var _is_active : bool 

#TODO decided if update rate should be exposed since children can not make an override
#export. also the children would be manually setting this base on the logic
#may have an override @export varible to controll the rate
var _update_rate : int

#NOTE: Local to scene is needed else reource is shared

#TODO: maybe make it so the node with this resource handle single or multiple interations

#the main trigger. children should override the functions with _
#and only override this if they want to completly override the logic
func interact(_handler, _interactor, _interactee, _data):
	if _is_active:
		print_debug("interaction is already active")
		return false
	handler = _handler
	interactor = _interactor
	interactee = _interactee
	data = _data
	_is_active = true
	_run()
	return true

func end_interact(canceled:bool = false):
	_end(canceled)
	finished.emit(canceled,self)
	#NOTE: probably should not clear it untill a new interaction
	#is_active can be the dirty flag
	#handler = null
	#instigator = null
	#interactee = null
	#data = {}
	_is_active = false

#the default run logic. will call all the steps with an update cycle if vaild
func _run():
	_start()
	started.emit(self)
	print_debug(str(interactor) + " interact with " +str(interactee) + " from(handler) " +  str(handler))
	while _update_rate and _is_active:
		await interactee.get_tree().create_timer(_update_rate).timeout
		_update()
		updated.emit(self)
	end_interact()
	#NOTE: connected need to disconnect itself
	#_owner will be who owns this. since the owner will be linking it, then it cna pass it self
	#_data is a placeholder for any extra data for now


#call on the start
func _start():
	pass
	
#call per update if it can
func _update():
	pass
	#updated.emit(data)

#called when the interaction is consider over
func _end(canceled:bool = false):
	pass
	#finished.emit(true,data)
