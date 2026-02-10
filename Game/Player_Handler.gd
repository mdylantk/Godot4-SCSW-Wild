class_name Player_Handler extends Node

@export var controller : Controller

@export var state : Player_State = Player_State.get_default_instance()
@export var game_state : Game_State = Game_State.get_default_instance()

var paused : bool = false:
	set(value):
		paused = value
		if !paused : return
		if controller != null :
			controller.set_direction(Vector2())
	
func on_new_game(path:String = "")->void:
	state.reset_state()
	
func on_game_loaded(path:String = ""):
	var full_path = path + "controllers/" + name + ".tres"
	var loaded_save : Savable_State
	if ResourceLoader.exists(full_path):
		loaded_save = ResourceLoader.load(full_path,"",0)
	print_debug("loaded",loaded_save,' ',full_path)
	if (loaded_save):
		state.load_data(loaded_save.data)
		
func on_autosave(path : String = ""):
	var new_save_state : Savable_State = Savable_State.new(state.get_save_data())
	var full_path = path + "controllers/"
	if !DirAccess.dir_exists_absolute(full_path):
		DirAccess.make_dir_recursive_absolute(full_path)
	full_path = full_path + name + ".tres"
	ResourceSaver.save(new_save_state, full_path)
	print_debug("autosaving ", full_path)
	

#NOTE: using game state here instead of expect the game to call it
#incase this is moved off the game handler.
func _ready():
	game_state.save_event.connect(on_autosave)
	game_state.load_event.connect(on_game_loaded)
	game_state.new_game_event.connect(on_new_game)

func _unhandled_input(event:InputEvent):
	if paused : return
	
	if event.is_action("Sprint"):
		if controller != null:
			controller.trigger_action("Sprint",event.get_action_strength("Sprint"))
			get_viewport().set_input_as_handled()

	if event.is_action_pressed("Accept"):
		if controller != null:
			controller.trigger_action("Interact",1)
			get_viewport().set_input_as_handled()
		
	if (event.is_action("Left") or event.is_action("Right") or
		event.is_action("Forward") or event.is_action("Back")
	):
		if controller != null:
			controller.set_direction(Vector2(
				Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")
			).normalized())
			get_viewport().set_input_as_handled()
