extends Canvas_Scene
#signal close(node:Node)

var current_line : int = 0 

#NOTE: text was loaded on ready, but decided it may be better
#loaded when open and freed when closed
#since it wont be used often and the size could be large
#also could redesign this to handle parts of it later
func load_text()->void:
	%Credits_Text.clear()
	var others_license = Engine.get_license_info.call()
	%Credits_Text.add_text("\n"+"Godot:\n\n")
	%Credits_Text.add_text(str(Engine.get_license_text()))
	for id in others_license.keys():
		%Credits_Text.add_text("\n\n"+str(id)+":\n\n")
		%Credits_Text.add_text(str(others_license[id]))

#func _ready() -> void:
#	pass

func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("Start") or event.is_action_pressed("Cancel"):
			#close.emit()
			end()
			get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	##This allow controller to scroll text box
	if Input.is_action_pressed("Forward") or Input.is_action_pressed("Back"):
		var scroll_amount: float = (
			Input.get_action_strength("Back") - Input.get_action_strength("Forward")
		)
		current_line = mini(maxi(int(current_line + scroll_amount),0),%Credits_Text.get_line_count())
		%Credits_Text.scroll_to_line(current_line)

func start()->void:
	load_text()
	super()
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	%Credits_Text.grab_focus()
	set_process(true)

func end()->void:
	current_line = 0
	%Credits_Text.scroll_to_line(current_line)
	super()
	set_process(false)
	%Credits_Text.clear()

func _on_visibility_changed() -> void:
	pass
	#if visible:
	#	%Credits_Text.grab_focus()
	#	set_process(true)
	#else:
	#	set_process(false)
	#	current_line = 0
