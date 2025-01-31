##This is the base object pass by the action run function that contains any nessary
##info for the action event. Extra meta data can be handle by children of this 
##or by using the metadata. The approch depends on what the system design to use
class_name Action_Data extends RefCounted

##the one that calls the actions
var owner : Node

##the one the action effects. May default to owner if null
var target : Node

func _init(new_owner:Node, new_target:Node = null,default_meta:Dictionary={}) -> void:
	owner = new_owner
	target = new_target
	if !default_meta.is_empty():
		for key in default_meta:
			set_meta(key, default_meta[key])
	
