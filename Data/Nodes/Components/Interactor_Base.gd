class_name Interactor_Base extends Node

signal interaction(interactor:Node, interactee:Node, data:Dictionary)

func interact(interactor:Node = owner):
	#Should call interaction.emit(). just need a target(interactee). 
	pass
