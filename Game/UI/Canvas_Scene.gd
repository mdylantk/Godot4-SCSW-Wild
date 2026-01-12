##This is a control node that reprents a holder of
##various control items. It is meant to be a wrapper
##for menus and widgets.
class_name Canvas_Scene extends Control

#NOTE: Will use show and hide from canvas item for visibilty
#but this cause limits. Generally show and hide logic should be simple
#check of visibity. open and close is where the state of the scene may change

signal ended()
signal started()

##Trigger the open logic of this scene
func start()->void:
	show()
	started.emit()
	
##Trigger the close logic of this scene
func end()->void:
	hide()
	ended.emit()

##This is reserver as a shared way to refresh the scene
func update()->void:
	pass
