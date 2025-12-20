#this is a way to check the ui status or listen to it indirectly
#but certain (more independent) ui should have their own state like
#object. 
class_name UI_State extends State

#NOTE: the main point of this state is the notify system
#the game state tend to handle what cause pausing and the
#other stuff could be gain by giving them their own state
#so this is more a placeholder untill each system is built up more
signal send_notifcation(message : String)

#NOTE: the id base calls only will work if ui supports it
#NOTE TODO : these are old and an abstract way to interact with the ui
#they might be kept or changed, but the state may need a var for the
#ui element that is in focus or an indentifier for advance cases
#though I probably should not depend on it. 
signal open(id:String, data:Variant)
#close will end it or unload it or clear that element
signal close(id:String)
#to show an element
signal show(id:String)
#to hid a element
signal hide(id:String)

#NOTE: not sure if this is used or from the old pause system
var enable_player_input :bool = true
#func send_notifcation(message : String):
#	event.emit('send_notifcation',"[center]"+message)
	#UI.gui_notify.add_notify_message("[center]"+message)

#this is a temp solution to acess the fishing ui
#should have its own state
var fishing_game = null
#var dialog = null
