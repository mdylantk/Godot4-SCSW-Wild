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

func send_notifcation(message:String):
	gui_notify.add_notify_message("[center]"+message)

#NOTE: this fine if menu is ment to be reused, but also
#the main menu may be better if it have the other memebers as children
#and just signal up if need UI to do somothing that can not be handled
#by watching main menu visibilty
func _on_main_menu_request_focus_change(id: String) -> void:
	%Main_Menu.visible = false
	match id:
		"options":
			%Options_Menu.visible = true
		"credits":
			%Credits_Menu.visible = true



func _on_submenu_close(node: Node) -> void:
	%Main_Menu.visible = true
	node.visible = false

##called when a menu(that overrides player input) visibilty change.
func _on_menu_visibility_changed() -> void:
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
		#TODO: have menu objects in one major scene so the lot can have their visibilty
		#changed all at once. That would allow they check only need to check
		#dyanmic elements(fishing and dialog), menu, and loading screen

func _ready() -> void:
	
	state.send_notifcation.connect(send_notifcation)
	state.fishing_game = fishing_game
	#state.dialog = gui_dialog
	
	_on_menu_visibility_changed()
	#TODO: try to let the game handler handle tree events such as pausing
	#this could read the tree if needing to know if paused if needed
	#the current scene should handle the UI state for cases where the UI dirves
	#the gameloop (aka start menu. main menu deviation should happpen because of
	#the start scene instead of solving it in the UI
	#get_tree().paused = true
	%Main_Menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pass
	

func _input(event: InputEvent) -> void:
	#NOTE: need to try to have input shortcut and other
	#menu triggers someplace here if only one can be in focus
	#so if inventory is open, menu can open above it.
	#this might be desired, but also one might want to close
	#the inventory when the menu is open (also would allow esc
	#to close the inventory since esc is reserve for the menu)
	#NOTE: it be bad to use _on_menu_visibility_changed() to force close
	#ui that is connected to it. so it be better if it communicate up when
	#it want to close or open. _on_menu_visibility_changed() can be kept
	#to make sure the focus state is correct, but need to not depend on visiblty
	#signal for deciding of other menus should be visible (or at least not in 
	#this class)
	if event.is_action_pressed('Inventory'):
		if state.ui_in_focus and %Cargo.visible:
			%Cargo.visible = false
			get_viewport().set_input_as_handled()
		elif !state.ui_in_focus:
			%Cargo.visible = true
			get_viewport().set_input_as_handled()
	if event.is_action_pressed("Start"):
		if (state.ui_in_focus and %Main_Menu.visible) or !state.ui_in_focus:
			#TODO: need a var for menus that allow main menu to upen
			#But that may be unessary. can handle escape in those menus
			#as a way to pause if needed. could give then a signal
			#so they can talk up and ask for the menu.
			#TODO: should try to handle mouse visiblity in ui or game and
			#not child or at least they should not hide it when not visible
			#the game should capture the mouse state before ui gain focus
			#Then use that capture to restore the mouse.
			%Main_Menu.escape()
			get_viewport().set_input_as_handled()
		elif (state.ui_in_focus and %Cargo.visible) or !state.ui_in_focus:
			#%Cargo.escape()
			%Cargo.visible = false
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
