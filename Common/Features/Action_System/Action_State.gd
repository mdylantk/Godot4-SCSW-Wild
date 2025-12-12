##This is the base object pass by the action run function that contains any nessary
##info for the action event. Extra meta data can be handle by children of this 
##or by using the metadata. The approch depends on what the system design to use
class_name Action_State extends RefCounted

##the one that calls the actions. most likly character2d
var owner : Node

##the one the action effects. most likly interaction component or
##null. maybe a character2d or some other node in odd cases
var target : Node


#NOTE: the action state might not be used for extended action
#other systems would keep track of the action.
#this is here incase it is still being used
var _action : Base_Action

func get_action() -> Base_Action:
	return _action

func _init(new_owner:Node, new_target:Node = null,default_meta:Dictionary={}) -> void:
	owner = new_owner
	target = new_target
	if !default_meta.is_empty():
		for key in default_meta:
			set_meta(key, default_meta[key])
	
