class_name A_Send_Notification extends Base_Action

@export var message : String

func _run(data:Action_State = null) -> bool:
	var format : Dictionary = {}
	if data:
		format = data.get_meta("format",{})
	General_Events.send_notifcation(message.format(format))
	return super(data)
