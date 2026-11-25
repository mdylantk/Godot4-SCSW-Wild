class_name A_Send_Notification extends Base_Action

@export var message : String

@export var ui_state : UI_State = UI_State.get_default_instance()

func _run(action_state:Action_State) -> bool:
	var format : Dictionary = {}
	if action_state:
		format = action_state.get_data("format",{})
	ui_state.send_notifcation.emit(message.format(format))
	return super(action_state)
