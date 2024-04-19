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
		%NotifyText.text = str(message) + message_extension
		#NOTE: below can help fit the messge to a max size, but may need text size
		#to fine tune it.
		%NotifyBox.size.y = (min(%NotifyText.get_line_count(),3)*12)+24
		visible = true
		notify_list.erase(message)
		if %NotifyText.get_line_count() > 2:
			for line in range(%NotifyText.get_line_count()):
				%NotifyText.scroll_to_line(line)
				await get_tree().create_timer(display_time).timeout
		await get_tree().create_timer(display_time).timeout
		handle_messages()
	else:
		visible = false
		is_active = false

func _ready():
#	Global.message_box = self
	visible = false
	
	
