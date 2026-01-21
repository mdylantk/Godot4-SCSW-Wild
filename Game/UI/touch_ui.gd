extends CanvasLayer
#NOTE: this is to allow touch users to play the game by proving gui to click on
#also would need to hide it by default if touch is not enabled

#this fake input events so that the game do not have to listen to extra signals
#but if a input is risky to fake, then this should expose it to the ui/game to
#listen too. 
func call_input_event(action:String, pressed:bool = true, strength:int = 1.0)->void:
	var input_event = InputEventAction.new()
	input_event.action = action
	input_event.pressed = pressed
	input_event.strength = strength
	Input.parse_input_event(input_event)


func _on_main_menu_button_pressed() -> void:
	call_input_event("Start")
	await get_tree().process_frame
	call_input_event("Start",false)


func _on_cargo_button_pressed() -> void:
	call_input_event("Inventory")
	await get_tree().process_frame
	call_input_event("Inventory",false)


func _on_up_button_down() -> void:
	call_input_event("Forward")
	pass # Replace with function body.


func _on_up_button_up() -> void:
	call_input_event("Forward",false)
	pass # Replace with function body.


func _on_down_button_down() -> void:
	call_input_event("Back")
	pass # Replace with function body.


func _on_down_button_up() -> void:
	call_input_event("Back",false)
	pass # Replace with function body.


func _on_right_button_down() -> void:
	call_input_event("Right")
	pass # Replace with function body.


func _on_right_button_up() -> void:
	call_input_event("Right",false)
	pass # Replace with function body.


func _on_left_button_down() -> void:
	call_input_event("Left")
	pass # Replace with function body.


func _on_left_button_up() -> void:
	call_input_event("Left",false)
	pass # Replace with function body.
	
func _process(delta: float) -> void:
	%Debug_Curser.position = get_viewport().get_mouse_position() + Vector2(8,8)
