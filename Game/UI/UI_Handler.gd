class_name UI_Handler extends Node


signal ui_focus(disable_other_input:bool)

##for the game handler to listen to. states that the game should be pause or resumed
##ideally the UI will be the only input that will request it. events(such as scene change)
##would trigger game to be pause and the game would need to decide when everything is ready

@export var hide_hud : bool = false :
	set(value):
		#NOTE: this might not be ideal unless hiding them all
		#look like it will show them all and loading screen as well
		#as dialog should only show when active
		#NOTE: look like it is used to make sure these menus are not visible
		#at the start of the game
		if value != hide_hud:
			hide_hud = value
			%LoadingScreen.visible = !hide_hud
			%Score.visible = !hide_hud
			%Dialog.visible = !hide_hud
			%Notify.visible = !hide_hud
			
@export var state : UI_State = load('uid://dkc6l4f8ve4t5')

#@export var world_state : World_State = load('uid://b047ftosxvj7p')

@onready var loading : bool = false :
	set(value):
		if(%LoadingScreen):
			%LoadingScreen.visible = value
		if loading != value: #nned these check so state do not get refreshed to an invaild one
			enable_player_input = !value
		###NOTE!!! below works. above do not disable input
		#Game.input.set_process_input(!value)
		loading = value
		#request_pause.emit(value)
	get:
		return %LoadingScreen.visible

#var in_main_menu:bool:
#	set(value):
#		in_main_menu = value
#		%Main_Menu.visible = value
		

#may not be the best, but exposing these so they can be called directly instead of having to look them up
#should only be for more static gui types
@onready var gui_notify := %Notify
@onready var gui_score := %Score
@onready var gui_dialog := %Dialog

#NOTE: expose menu should also follow guildlines as the handler
#they are, more or less, another independent system to listen to
#so the game menu should provide signals so the game can run the game
#spec logic
@onready var main_menu : Main_Menu = %Main_Menu

@onready var fishing_game := %FishingPondMap

##enable the input for the player controller, else
##player contoller will nopt process the input
@export var enable_player_input : bool = true

var focus_menu : Canvas_Scene 

func send_notifcation(message:String):
	gui_notify.add_notify_message("[center]"+message)

func change_menu(new_menu:Canvas_Scene ):
	var old_menu : Canvas_Scene = focus_menu
	if old_menu == new_menu:
		return
	focus_menu = new_menu
	if old_menu:
		old_menu.end()
	if new_menu:
		new_menu.start()
		state.ui_in_focus = true
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		state.ui_in_focus = false
		#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	state.update_mouse_mode()
	ui_focus.emit(state.ui_in_focus)
	on_focus_change()

func on_focus_change():
	if state.ui_in_focus:
		if $DebugHUD.enable_debug:
			$DebugHUD.visible = false
		if state.is_touch_enable:
			$Touch_UI.visible = false
	else:
		if $DebugHUD.enable_debug:
			$DebugHUD.visible = true
		if state.is_touch_enable:
			$Touch_UI.visible = true
#this is a failsafe since the current system require a certain call order
#and this will get the menu that is visible base on importaince
#so call order would not be as importaint as long as this is called
#instead
#NOTE: this may be useful instead of calling null
#since it allow it to check if any menu is still visible
func get_visible_menu()->Node:
	if %Main_Menu.visible:
		return %Main_Menu
	if %Cargo.visible:
		return %Cargo
	if %Options_Menu.visible:
		return %Options_Menu
	if %Credits_Menu.visible:
		return %Credits_Menu
	return null
	
func _on_menu_close() -> void:
	#if focus_menu == %Main_Menu:
	#	change_menu(null)
	change_menu(get_visible_menu())

func _on_submenu_close() -> void:
	change_menu(%Main_Menu)
	#change_menu(get_visible_menu())

func _on_options_pressed()->void:
	change_menu(%Options_Menu)

func _on_credits_pressed()->void:
	change_menu(%Credits_Menu)

##called when a menu(that overrides player input) visibilty change.
func _on_menu_visibility_changed() -> void:
	#NOTE: This is still needed for
	#the fishing and dialog.
	#dialog could use the logic from menu_layer
	#but fishing is its own thing. so need to decided 
	#on how to handle fishing for the new set up
	state.ui_in_focus = (
		%Dialog.visible or
		%FishingPondMap.visible or 
		%Main_Menu.visible or 
		%LoadingScreen.visible or
		%Credits_Menu.visible or
		%Options_Menu.visible or 
		%Cargo.visible
	)
	ui_focus.emit(state.ui_in_focus)
	on_focus_change()
		#TODO: have menu objects in one major scene so the lot can have their visibilty
		#changed all at once. That would allow they check only need to check
		#dyanmic elements(fishing and dialog), menu, and loading screen

func _on_touch_ui_changed()->void:
	if state.is_touch_enable and !state.ui_in_focus:
		$Touch_UI.visible = true
	else:
		$Touch_UI.visible = false

func _ready() -> void:
	
	state.send_notifcation.connect(send_notifcation)
	state.fishing_game = fishing_game
	#state.dialog = gui_dialog
	
	#_on_menu_visibility_changed()
	change_menu(%Main_Menu)
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	%Main_Menu.options_pressed.connect(_on_options_pressed)
	%Main_Menu.credits_pressed.connect(_on_credits_pressed)
	%Main_Menu.ended.connect(_on_menu_close)
	%Credits_Menu.ended.connect(_on_submenu_close)
	%Options_Menu.ended.connect(_on_submenu_close)
	%Cargo.ended.connect(_on_menu_close)
	
	#calling to set the state if it changed before it was connected
	_on_touch_ui_changed()
	state.touch_enable.connect(_on_touch_ui_changed)

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed('Inventory'):
		if state.ui_in_focus and %Cargo.visible:
			%Cargo.end()
			change_menu(get_visible_menu())
			get_viewport().set_input_as_handled()
		elif !state.ui_in_focus:
			change_menu(%Cargo)
			get_viewport().set_input_as_handled()
			
	if event.is_action_pressed("Start"):
		if !state.ui_in_focus:
			change_menu(%Main_Menu)
			get_viewport().set_input_as_handled()


#TODO: try not to ref handler in UI. currenly only for tests and debug
#if need to ref an handler, can move the logic to a child ideally one that
#is not expose as a var
func _process(_delta):
	var camera_global_position : Vector2
	if get_viewport().get_camera_2d() != null:
		camera_global_position = get_viewport().get_camera_2d().global_position
	if !Engine.is_editor_hint():
		var current_size = get_viewport().get_visible_rect().size
			#if player_pawn != null:
		if camera_global_position.length() > current_size.length() :
			%HomePoint.visible = true
			%HomePoint/TextureRect.position = (-(camera_global_position - Vector2(16*32,16*32))).clamp(Vector2.ZERO, (current_size -Vector2(16,16)))
				#Vector2(16*32,16*32) is the offset. should be the player orginal spawn or the old man global location
		else:
			%HomePoint.visible = false
			##NOTE AND TODO: decide if there a better way than calling game here to get
			#world. could hold a world parameter the game can set.
			#or could have the game handle loading flag in regards to world and system
			#but then there need signals or direct calls to set that and world loading
			#not as simple
			#NOTE: by checking four corner point, boader loading cases could be solved
	if focus_menu:
		$DebugHUD.ui_message = 'focus: ' + focus_menu.name + ' : ' + str(state.ui_in_focus)
	else:
		$DebugHUD.ui_message = 'focus: ' + str(focus_menu) + str(state.ui_in_focus)
