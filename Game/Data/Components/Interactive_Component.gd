class_name Interactive_Component extends Node#StaticBody2D
#Note: will be a Node. children can then be allowed to connect to other node functions
#like area2D overlap stuff
signal started(data:Interactive_Data)
signal updated(data:Interactive_Data)
signal finished(canceled:bool, data:Interactive_Data, caller:Node)

#NOTE:THIS might work, just move the state here and leave data as logic and 
#static state.

@export var interactive_data : Interactive_Data

var active_data :Dictionary[Node,Interactive_Data]
func register_data(caller:Node, data:Interactive_Data):
	if caller == null or data == null:
		return
	if active_data.has(caller):
		return
	active_data.set(caller,data)
	data.finished.connect(on_finished)
	data.updated.connect(on_update)
func unregister_data(caller:Node):
	var data = active_data.get(caller)
	if data:
		data.finished.disconnect(on_finished)
		data.updated.disconnect(on_update)
	active_data.erase(caller)

#Note: the use of these is to notify the owner
#but it may not be needed for this project
func on_update(data):
	updated.emit(data)
#this one is used for clean up, but the finished signal emiter
#might not be needed
func on_finished(canceled:bool,data, caller=null):
	finished.emit(canceled, data)
	#NOTE: the data passed should be used
	#for other nodes. this will use this to clear up 
	#the data
	unregister_data(caller)
	
#NOTE: interactee will be self. interact data can have an override or use
#interactee.owner if it wants more data
func interact(interactor, interactee = self, metadata = {}):
	if interactive_data != null:
		if !active_data.has(interactor):
			register_data(interactor, interactive_data.duplicate())
		var data = active_data.get(interactor)
		
		if data._is_active:
			#TODO: decide on handling coping the data instead
			#and logging them by triggerer so more than one interaction
			#can be handled.
			print_debug('Notice: interactive data is active.')
			#TODO: need to handle if active. could just ignore,
			#but should do something and if ignore maybe return null
		elif data.interact(interactor, interactee, metadata):
			started.emit(data)
		return data
