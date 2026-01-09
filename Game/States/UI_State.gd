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
#var dialog = null
