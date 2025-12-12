class_name A_Send_Notification extends Base_Action

@export var message : String

@export var ui_state : UI_State = load('uid://dkc6l4f8ve4t5')

func _run(data:Action_State = null) -> bool:
	var format : Dictionary = {}
	if data:
		format = data.get_meta("format",{})
	ui_state.send_notifcation.emit(message.format(format))
	return super(data)
