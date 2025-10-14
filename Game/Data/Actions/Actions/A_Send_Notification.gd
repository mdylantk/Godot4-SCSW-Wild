class_name A_Send_Notification extends Base_Action

@export var message : String

@export var ui_events : Events_UI = preload('uid://dkc6l4f8ve4t5')

func _run(data:Action_State = null) -> bool:
	var format : Dictionary = {}
	if data:
		format = data.get_meta("format",{})
	#TODO: Either a event resource or the game_state could have
	#a way to communiate up to a node to emit a message
	ui_events.send_notifcation.emit(message.format(format))
	#General_Events.send_notifcation(message.format(format))
	return super(data)
