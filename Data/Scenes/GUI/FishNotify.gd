extends CanvasLayer


@export var display_time : float = 1

var notify_list = {}
var is_active = false

func add_notify_message(message = "", amount = 1):
	if message != "" :
		if amount != 0: #if 0, it just nulls it.
			if notify_list.has(message) :
				notify_list[message] += amount
				if notify_list[message] <= 0:
					#remove it since it is null now
					notify_list.erase(message)
			elif amount > 0:
				notify_list[message] = amount
	if is_active == false:
		handle_messages()



		
func handle_messages() :
	#while is_active:
	if !notify_list.is_empty():
		is_active = true
		print(notify_list)
		print("awaiting")
		var message = notify_list.keys()[0]
		var amount = notify_list[message]
		var message_extension = ""
		if amount > 1:
			message_extension = " (x" + str(amount) + ")"
		$NotifyText.text = str(message) + message_extension
		#$NotifyText.text = "[center]Caught a " + str(fish_name)
		visible = true
		notify_list.erase(message)
		await get_tree().create_timer(display_time).timeout
		handle_messages()
	else:
		visible = false
		is_active = false

func _ready():
#	Global.message_box = self
	visible = false
	
	
