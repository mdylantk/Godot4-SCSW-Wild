##This is a class to provide basic menu functions and signals
##for layered menus. (These are in focus set of ui elements that 
##interact with each other. Menus tend to be hidden and pause when
##not in focus and may have a share state to help give it context
##for cases not handled bu the ui managers or handlers).
class_name Canvas_Menu extends CanvasLayer

#will not emit a signal for visibilty since can use the built in
#but functions to request change may be provided for more flow controll
signal closed()
signal opened()


func open()->void:
	visible = true
	opened.emit()
	
func close()->void:
	visible = false
	closed.emit()
