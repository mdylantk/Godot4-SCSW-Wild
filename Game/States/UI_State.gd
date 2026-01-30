#this is a way to check the ui status or listen to it indirectly
#but certain (more independent) ui should have their own state like
#object. 
class_name UI_State extends State

#NOTE: the main point of this state is the notify system
#the game state tend to handle what cause pausing and the
#other stuff could be gain by giving them their own state
#so this is more a placeholder untill each system is built up more
signal send_notifcation(message : String)

#NOTE: may used these as surface level controls
#but some ui elements will have a state which will handle showing
#the menu or not. 
#id can be formated incase a submenu also need to display, but the ui
#would handle converting and passing that so no extra data should be pass
#(use a dedicated state for that menu if it need data)

#also i think the ui is watching over the menu visibilty so things
#like pausing and deciding what menus can be open would be done by that

signal open(id:String)
#close will end it or unload it or clear that element
signal close(id:String)
#to show an element
signal show(id:String)
#to hid a element
signal hide(id:String)

signal touch_enable()

var is_touch_enable : bool :
	set(value):
		if is_touch_enable != value:
			is_touch_enable = value
			if is_touch_enable:
				unfocus_mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				unfocus_mouse_mode = Input.MOUSE_MODE_HIDDEN
			touch_enable.emit()

##The default mouse mode for interactive gui elements
##Used to reset focus_mouse_mode if being manually overrided
var default_mouse_mode:Input.MouseMode = Input.MOUSE_MODE_VISIBLE

##The mouse mode for when the gui is not in focus.
##The game should set this depending on the input type
##also game should have a way to restore it to default.
var unfocus_mouse_mode:Input.MouseMode = Input.MOUSE_MODE_HIDDEN

##The mouse mode when the gui is in focus
var focus_mouse_mode:Input.MouseMode = Input.MOUSE_MODE_VISIBLE


##states if the ui is in focus at all
var ui_in_focus : bool = false
#NOTE: not sure if this is used or from the old pause system
var enable_player_input :bool = true
#func send_notifcation(message : String):
#	event.emit('send_notifcation',"[center]"+message)
	#UI.gui_notify.add_notify_message("[center]"+message)
	
#this is a temp solution to acess the fishing ui
#should have its own state
var fishing_game = null
var pounce_fishing_state : Pounce_Fishing_State
#var dialog = null

##this will make sure the mouse mode is update
##after changing unfocus_mouse_mode or focus_mouse_mode
##NOTE: focus_mouse_mode is not meant to be change often
##and may lead to undesire resualts if gui elements switch mouse modes
func update_mouse_mode()->void:
	if ui_in_focus:
		Input.mouse_mode = focus_mouse_mode
	else:
		Input.mouse_mode = unfocus_mouse_mode
