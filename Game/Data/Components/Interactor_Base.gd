class_name Interactor_Base extends Node2D

signal interaction(interactor:Node, interactee:Node, data:Dictionary)

##returns the first child node that is consider an Interactor_Base
static func find_vaild_child(parent:Node)->Interactor_Base:
	for child:Node in parent.get_children():
		var child_as_type = child as Interactor_Base
		if child_as_type != null:
			return child_as_type
	return null

func interact(interactor:Node = owner):
	#Should call interaction.emit(). just need a target(interactee). 
	pass
