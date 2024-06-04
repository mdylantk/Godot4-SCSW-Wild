class_name General_Events extends Object


#NOTE: bringing this back to solve an issue with signals and newly created object
#being mess up due to either gc or timing issues
#NOTE: the point of this is to not call Game directly as well as isolate
#these functions so they can be found easier. also can modify ther path without breaking
#a lot in the case of magor system redesign
	
static func get_world():
	return World

#Not needed if autoload
#static func get_HUD():
#	return Hud
	
#can add a get_player, but for now it not needed
	
static func spawn_entity(entity:Node):
	World.add_child(entity)
	
static func change_level(level:Object, handler:Node, instigator:Node, offset:Vector2):
	World.change_level(level,handler,instigator,offset)
	
static func start_dialog(dialog_data):
	UI.gui_dialog.open_dialog(dialog_data)

static func send_notifcation(message : String):
	UI.gui_notify.add_notify_message("[center]"+message)
