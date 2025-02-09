class_name Main_Menu extends CanvasLayer
signal request_focus_change(id:String)

signal resume()
signal pause()
signal new_game(id:String)
signal load_game(id:String)
signal end_game()


#@export var options_menu : Node
#@export var credits_menu : Node

@export var default_focus : Array[Control]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Start"):
		if visible && %Resume_Button.visible:
			visible = false
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			resume.emit()
			#get_tree().paused = false
			get_viewport().set_input_as_handled()
			
		else:
			visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pause.emit()
			#get_tree().paused = true
			get_viewport().set_input_as_handled()

func _on_resume_button_pressed() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	resume.emit()
	#get_tree().paused = false
	print_debug("resume pressed")


func _on_new_game_button_pressed() -> void:
	#Game.start_game(true)
	print_debug("new game pressed")
	%Resume_Button.visible = true
	#%LoadingScreen.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	#get_tree().paused = false
	#NOTE! hiding new game untill a restart system is added
	visible = false
	%New_Game_Button.visible = false
	%Continue_Button.visible = false
	#%HomePoint.visible = true
	
	new_game.emit()

func _on_options_button_pressed() -> void:
	print_debug("options pressed")
	request_focus_change.emit("options")
	#options_menu.visible = true


func _on_exit_button_pressed() -> void:
	print_debug("exit pressed")
	#Game.end_game(true)
	end_game.emit()


func _on_credits_button_pressed() -> void:
	print_debug("credits pressed")
	request_focus_change.emit("credits")
	#credits_menu.visible = true


func _on_continue_button_pressed() -> void:
	#Game.start_game(false)
	print_debug("continue pressed")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	#get_tree().paused = false
	visible = false
	%Resume_Button.visible = true
	%Continue_Button.visible = false
	%New_Game_Button.visible = false
	load_game.emit("Default")

func _ready() -> void:
	_on_visibility_changed()

func _on_visibility_changed() -> void:
	if visible and !default_focus.is_empty():
		for focus_object in default_focus:
			if focus_object.visible:
				focus_object.grab_focus()
				break
