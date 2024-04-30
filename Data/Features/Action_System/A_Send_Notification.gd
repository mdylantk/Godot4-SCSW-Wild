class_name A_Send_Notification extends Base_Action

@export var message : String

func run(data:={}):
	General_Events.send_notifcation(message.format(data))
