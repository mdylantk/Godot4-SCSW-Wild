class_name General_Events extends Object

#a way to quickly generate event data. may not be needed anymore
#TODO: expand on this to include types
static func make_event_data(type="event", id = "0"):
	return {
		"type":type,
		"id": id,
		"status":1,
		"run":func(data):
			print_debug("nothing to run") 
			data["status"] = 0
	}

#NOTE: and TODO: static functions for events are for system and handle level logic
#groups should be use if the event need many sources or dynamic sources
#though the base functinaly may be hosted here or other static events scripts.
#also same goses with signals. they are for upward notifcation of dynamic nodes
#while groups are a downward notifcation and/or request to dynamic node
#this is for direct communication of importaint and mostly static systems from any source 
#(well they should be sources with a abstraction like with modual actions)
#though it could be solve with signals, these system would end up handling much more 
#if they handle all the possible signals. this ment to break up the logic into smaller files
#and have them handle in a static way.


#static func get_game_handler():
#	print_debug("(2)TODO: this should not be called. will be remove soon")
	#this is a place holder. if Game is not auto load, other logic would be needed
	#so this is here to provide that or allow a controlled area so chaning autoload
	#wont break things all over the place (just need to update this)
#	return Game
	
#static func change_level(level, handler):
#	Game.world.change_level(level,handler)
	
#static func start_dialog(handler, speaker, dialog_data):
#	Game.hud.gui_dialog.open_dialog(dialog_data)
	#handler.hud.gui_dialog.start_dialog(speaker, dialog_data)
	#handler.get_hud().gui_dialog.start_dialog(speaker, dialog_data)

#static func send_notifcation(message : String):
#	Game.hud.gui_notify.add_notify_message("[center]"+message)
	#handler.hud.gui_notify.add_notify_message("[center]"+message)
