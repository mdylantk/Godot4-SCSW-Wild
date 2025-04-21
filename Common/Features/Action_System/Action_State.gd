##This is the base object pass by the action run function that contains any nessary
##info for the action event. Extra meta data can be handle by children of this 
##or by using the metadata. The approch depends on what the system design to use
class_name Action_State extends RefCounted

##the one that calls the actions
var owner : Node

##the one the action effects. May default to owner if null
var target : Node

##This is a ref of the action this belongs to.
##It is stored here incase the action state needs to last more than one cycle.
##without worry about lossing the action reference
##otherwise this would not be nessary. data.get_action.run(data)
##may seem odd though so I am not sure if I will keep it or
##have the tasks be stored in a object/array (though that sounds redundent) 
var _action : Base_Action

func get_action() -> Base_Action:
	return _action

func _init(new_owner:Node, new_target:Node = null,default_meta:Dictionary={}) -> void:
	owner = new_owner
	target = new_target
	if !default_meta.is_empty():
		for key in default_meta:
			set_meta(key, default_meta[key])
	
