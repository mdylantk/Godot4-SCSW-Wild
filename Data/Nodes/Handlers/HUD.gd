class_name HUD extends CanvasLayer

#generic signal that state when a gui scene been update...if said update emit it(placeholder mostly)
#currently no use since most update per process. also children may call their own, but may also call this
#to let others know the object ref so they could connect if needed
signal gui_update(element)

@export var hide_hud : bool = false :
	set(value):
		if value != hide_hud:
			hide_hud = value
			%LoadingScreen.visible = !hide_hud
			%Score.visible = !hide_hud
			%Dialog.visible = !hide_hud
			%Notify.visible = !hide_hud
	get:
		return hide_hud
		
@onready var loading : bool = false :
	set(value):
		if(%LoadingScreen):
			%LoadingScreen.visible = value
		Game.input.enable_input = !value
		###NOTE!!! below works. above do not disable input
		#Game.input.set_process_input(!value)
		loading = value
	get:
		return %LoadingScreen.visible

#may not be the best, but exposing these so they can be called directly instead of having to look them up
#should only be for more static gui types
@onready var gui_notify := %Notify
@onready var gui_score := %Score
@onready var gui_dialog := %Dialog

@onready var fishing_game := %FishingPondMap

@onready var debug : Label = %Debug
@export var enable_debug : bool = true


var player_handler : Player_Handler

#var player_state : Savable_State
#var player_pawn 
#func _ready():
	#pass

func handler_setup(handler):
	var common_fish_count = Savedata_Helper.fetch_player_score(handler,"common_fish_caught")
	var rare_fish_count = Savedata_Helper.fetch_player_score(handler,"rare_fish_caught")
	%Score.set_common_score(common_fish_count)
	%Score.set_rare_score(rare_fish_count)

func on_player_state_change(source, id, old_value, new_value, group):
	if old_value == new_value:
		#NOTE: need a way to know of changes if state is loaded or have
		#predetermin values. could grab from player
		return
	if group == "scores":
		if id == "common_fish_caught":
			%Score.set_common_score(new_value)
		elif id == "rare_fish_caught":
			%Score.set_rare_score(new_value)

func _ready() -> void:
	get_tree().paused = true
	%Main_Menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(_delta):
	var camera_global_position : Vector2
	if get_viewport().get_camera_2d() != null:
		camera_global_position = get_viewport().get_camera_2d().global_position
	if !Engine.is_editor_hint():
		if player_handler == null :
			return
		#TODO: have the player handler set a state for this to use
		#so this would need a state to use for player and any other needed states
		#if player_state != null:
		if player_handler.state != null:
			var player_state = player_handler.state
	
		#this being put here untill a timer or state system can take care of it
		#var player_pawn = Game.get_player_handler().pawn
		if player_handler.pawn != null:
			var player_pawn = player_handler.pawn
		#testing a way to point back to home
		#print(get_viewport().get_visible_rect().size)
			var current_size = get_viewport().get_visible_rect().size
			#if player_pawn != null:
			if player_pawn.global_position.length() > current_size.length() :
				%HomePoint.visible = true
				%HomePoint/TextureRect.position = (-(player_pawn.global_position - Vector2(16*32,16*32))).clamp(Vector2.ZERO, (current_size -Vector2(16,16)))
				#Vector2(16*32,16*32) is the offset. should be the player orginal spawn or the old man global location
			else:
				%HomePoint.visible = false
			##NOTE AND TODO: decide if there a better way than calling game here to get
			#world. could hold a world parameter the game can set.
			#or could have the game handle loading flag in regards to world and system
			#but then there need signals or direct calls to set that and world loading
			#not as simple
			#NOTE: by checking four corner point, boader loading cases could be solved
			
			loading = not (
				Game.world.is_chunk_loaded(camera_global_position + Vector2(320,320)) and
				Game.world.is_chunk_loaded(camera_global_position + Vector2(-320,320)) and
				Game.world.is_chunk_loaded(camera_global_position + Vector2(320,-320)) and
				Game.world.is_chunk_loaded(camera_global_position + Vector2(-320,-320))
				)
		if enable_debug:
			debug.text = str(camera_global_position)
			#debug.get_canvas_transform().affine_inverse() * debug.get_screen_position()
		
#func loading(is_loading):
	#await get_tree().create_timer(1).timeout #A delay so things can finish up. currrenty need to be appled difftrently or not used
#	$LoadingScreen.visible = is_loading

#NOTE: Main Menu Logic


func _on_resume_pressed() -> void:
	%Main_Menu.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().paused = false
	print_debug("resume pressed")

func _on_new_game_pressed() -> void:
	Game.start_game()
	print_debug("new game pressed")
	%Resume_Button.visible = true
	%LoadingScreen.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().paused = false
	#NOTE! hiding new game untill a restart system is added
	%Main_Menu.visible = false
	%New_Game_Button.visible = false
	%HomePoint.visible = true

func _on_options_pressed() -> void:
	print_debug("options pressed")
	var volume = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	%Music_Volume_Slider.value = volume
	%Options_Menu.visible = true

func _on_credits_pressed() -> void:
	print_debug("credits pressed")
	%Credits_Menu.visible = true
	#NEED a better way to see if it populated. this just to make sure it woring
	if %Credits_Text.get_line_count() <= 1:
		var others_license = Engine.get_license_info.call()
		%Credits_Text.add_text("\n"+"Godot:\n\n")
		%Credits_Text.add_text(str(Engine.get_license_text()))
		for id in others_license.keys():
			%Credits_Text.add_text("\n\n"+str(id)+":\n\n")
			%Credits_Text.add_text(str(others_license[id]))


func _on_exit_pressed() -> void:
	print_debug("exit pressed")
	get_tree().quit()

func _input(event: InputEvent) -> void:
	

	if event.is_action_pressed("Start"):
		var menu : Node = %Main_Menu
		if %Credits_Menu.visible:
			%Credits_Menu.visible = false
		elif %Options_Menu.visible:
			%Options_Menu.visible = false
		#NOTE: why dose this work? shouldn't Resume_Button.visible = false
		#to state game is not running? I mean a var should be made somewhere
		#that state the running state of the game.
		elif menu.visible && %Resume_Button.visible:
			menu.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			get_tree().paused = false
			
		else:
			menu.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
	elif event.is_action_pressed("Cancel"):
		#NOTE: it may be best not to have cancel resume game
		#or exit menu that have interaction
		#TODO: design the input flow so that this is called after
		#the other menu so menus can consume the input if used.
		#could also try having buttons use the UI_Input and this 
		#use the one that get called after (_input?) or the later ones
		#depending on the depth of the input map. may beable use the focus option to narrow
		#things down
		if %Credits_Menu.visible:
			%Credits_Menu.visible = false
		elif %Options_Menu.visible:
			%Options_Menu.visible = false
func _on_music_volume_slider_value_changed(value: float) -> void:
	#var music_player : AudioStreamPlayer = Game.world.get_node("AudioStreamPlayer")
	#var new_volume = 1*log(20/100)
	#music_player.\
	#log(x) / log(10)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

	#linear_to_db()
	pass # Replace with function body.

