extends CanvasLayer


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
			visible = false
			get_viewport().set_input_as_handled()
		
