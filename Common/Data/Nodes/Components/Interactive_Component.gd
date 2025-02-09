class_name Interactive_Component extends Node#StaticBody2D
#Note: will be a Node. children can then be allowed to connect to other node functions
#like area2D overlap stuff
signal started(data:Interactive_Data)
signal updated(data:Interactive_Data)
signal finished(canceled:bool, data:Interactive_Data)

#NOTE:THIS might work, just move the state here and leave data as logic and 
#static state.

@export var interactive_data : Interactive_Data:
	set(value):
		if value != null and interactive_data != value:
			interactive_data = value
			interactive_data.finished.connect(on_finished)
			interactive_data.updated.connect(on_update)
		else:
			interactive_data = value

#func _ready():
	#if interactive_data != null and !interactive_data.finished.is_connected(on_finished):
	#	interactive_data.finished.connect(on_finished)
#	pass

#TODO: on_start, and on_update should be link directly to the interactions data
#and the owner who need to know. if linked here, then it is to let the owner know 
#there been a change
func on_update(data):
	updated.emit(data)
func on_finished(canceled:bool,data):
	finished.emit(canceled, data)
	
#NOTE: interactee will be self. interact data can have an override or use
#interactee.owner if it wants more data
func interact(handler, interactor, interactee = self, data = {}):
	if interactive_data != null:
		if interactive_data.interact(handler, interactor, interactee, data):
			started.emit(interactive_data)
			return interactive_data
