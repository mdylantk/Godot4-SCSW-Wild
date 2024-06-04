##This is the base class for controllers. Player and AI controllers should extend from this
class_name Controller_Handler extends Node

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

