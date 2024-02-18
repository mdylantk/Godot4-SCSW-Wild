class_name General_Events extends Object

#a way to quickly generate event data
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
	
static func change_level(level, handler):
	handler.get_tree().call_group("World_Handler", "change_level", level,handler)
	
static func start_dialog(handler, speaker, dialog_data):
	handler.hud.gui_dialog.start_dialog(speaker, dialog_data)
	#handler.get_hud().gui_dialog.start_dialog(speaker, dialog_data)

static func send_notifcation(handler, message : String):
	handler.hud.gui_notify.add_notify_message("[center]"+message)
