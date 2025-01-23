##This is the base class for controllers. Player and AI controllers should extend from this
class_name Controller_Handler extends Node

##This is the default brain the controller will use to talk to its owning units
##controllers could use more than one brain, but usally one is all that is needed
##(note: the brain can contain slots for a behavor tree. controller just assignt varibles
##that may not be known by the pawn. imagin a hivemind calling to its minions to come home
##the handler would set the prority to return home and make sure home location is the hive
##the the minions will try to reach it while doing other tasks base on the brains logic and 
##componets. NOTE: the brain do not need to have componets for this as long as it have
##signals for the pawn to listen to. then it be more of a messager system) 
@export var controller_brain : Base_Brain :
	set(value):
		#this just a failsafe. Normally brain should not be freed 
		#unless major change in game mode 
		if controller_brain != value:
			if controller_brain  != null:
				controller_brain.removed.emit()
				#could also try to free it
		controller_brain = value

##NOTE: this is plan to replace controller brain
##(brain and controllers should be seperated. A brain may have a controller assign)
@export var controller : Controller
#NOTE: may not add the remove logic. controllers should not be created dymanicly
#remove may be added if game require the controller to change in the handler

func get_state()->Savable_State:
	return null

##returns a node the controller is controlling. index is used if the controll 
##is controlling more than one pawn.
func get_pawn(index:int=0)->Node:
	return null

##shared functionality that state that a new pawn should be controlled
##AI may stash it in an array while player may replace the current pawn
func handle_pawn(pawn:Node)->void:
	pass
##shared functionality that state that a new pawn should no longer be controlled
##If player only have one pawn, this would remove it and the player lose acess to a pawn
##if handle pawns are stored in an array, then they would be removed
func unhandle_pawn(pawn:Node)->void:
	pass
	
func on_level_changed(level:Base_Level, spawn_index: int = 0):
	pass
	
func _ready() -> void:
	World.level_changed.connect(on_level_changed)
