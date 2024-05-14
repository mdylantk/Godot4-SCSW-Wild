extends CanvasLayer
signal close(node:Node)

var current_line : int = 0 

func _ready() -> void:
	var others_license = Engine.get_license_info.call()
	%Credits_Text.add_text("\n"+"Godot:\n\n")
	%Credits_Text.add_text(str(Engine.get_license_text()))
	for id in others_license.keys():
		%Credits_Text.add_text("\n\n"+str(id)+":\n\n")
		%Credits_Text.add_text(str(others_license[id]))

func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("Start") or event.is_action_pressed("Cancel"):
			close.emit(self)
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	##This allow controller to scroll text box
	if Input.is_action_pressed("Forward") or Input.is_action_pressed("Back"):
		var scroll_amount: float = (
			Input.get_action_strength("Back") - Input.get_action_strength("Forward")
		)
		current_line = mini(maxi(int(current_line + scroll_amount),0),%Credits_Text.get_line_count())
		%Credits_Text.scroll_to_line(current_line)

func _on_visibility_changed() -> void:
	if visible:
		%Credits_Text.grab_focus()
		set_process(true)
	else:
		set_process(false)
		current_line = 0
