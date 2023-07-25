extends CanvasLayer

func _ready():
	Global.message_box = self
	visible = false
	
func set_message(fish_name):
	visible = true
	$FishNotifyText.text = "[center]Caught a " + str(fish_name)
	
	await get_tree().create_timer(1).timeout
	
	visible = false
	
