##This is the base class for controllers. Player and AI controllers should extend from this
class_name Controller_Handler extends Node

func get_state()->Savable_State:
	return null

##returns a node the controller is controlling. index is used if the controll 
##is controlling more than one pawn.
func get_pawn(index:int=0)->Node:
	return null

