class_name UI_State extends State
#TODO: maybe convert to a state and relocate some
#stateful general ui stuff here
signal send_notifcation(message : String)

#NOTE: the id base calls only will work if ui supports it
#NOTE TODO : may use an enum and compress them into a single signal to set the state
#maybe call it change_window_state(id, state) or update_window
#open is a general ui element. data usally a object/resource or dictionary 
#and may not be needed depending on the design
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
var dialog = null
