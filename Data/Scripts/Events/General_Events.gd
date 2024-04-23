class_name General_Events extends Object


#NOTE: bringing this back to solve an issue with signals and newly created object
#being mess up due to either gc or timing issues
#NOTE: the point of this is to not call Game directly as well as isolate
#these functions so they can be found easier. also can modify ther path without breaking
#a lot in the case of magor system redesign
	
static func get_world():
	return Game.world

#Not needed if autoload
#static func get_HUD():
#	return Hud
	
#can add a get_player, but for now it not needed
	
static func spawn_entity(entity:Node):
	Game.world.add_child(entity)
	
static func change_level(level:Level_Data, handler:Node, instigator:Node, offset:Vector2):
	Game.world.change_level(level,handler,instigator,offset)
	
static func start_dialog(dialog_data):
	Hud.gui_dialog.open_dialog(dialog_data)

static func send_notifcation(message : String):
	Hud.gui_notify.add_notify_message("[center]"+message)
