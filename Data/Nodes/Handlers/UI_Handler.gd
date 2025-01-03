class_name UI_Handler extends Node

#generic signal that state when a gui scene been update...if said update emit it(placeholder mostly)
#currently no use since most update per process. also children may call their own, but may also call this
#to let others know the object ref so they could connect if needed
signal gui_update(element)

signal ui_focus(disable_other_input:bool)

##for the game handler to listen to. states that the game should be pause or resumed
##ideally the UI will be the only input that will request it. events(such as scene change)
##would trigger game to be pause and the game would need to decide when everything is ready

@export var hide_hud : bool = false :
	set(value):
		if value != hide_hud:
			hide_hud = value
			%LoadingScreen.visible = !hide_hud
			%Score.visible = !hide_hud
			%Dialog.visible = !hide_hud
			%Notify.visible = !hide_hud

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

@onready var debug : Label = %Debug
@export var enable_debug : bool = true


#var player_state : Savable_State
#var player_pawn 
#func _ready():
	#pass

func handler_setup():
	#NOTE: GUI may ask for handler or listen for handler, since there little reason
	#for game or anything else to acces HUD. HUD ment to observe all and act like input
	var common_fish_count = Savedata_Helper.fetch_player_score(Player,"common_fish_caught")
	var rare_fish_count = Savedata_Helper.fetch_player_score(Player,"rare_fish_caught")
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
	
	#Player.state.data_changed.connect(on_player_state_change)
	#handler_setup()

func on_player_created(player:Node, index : int):
	if index == 0: #0 should be host or owning client. may need a better way or a built in way
		Player.state.data_changed.connect(on_player_state_change)
		handler_setup()

#general gameplay input for player. may need to have player handle this
#directly and pause the player if game is pause or gameplay is paused
#func _unhandled_input(event:InputEvent):
#	if enable_player_input: 
#		Player.input_update(event)
		

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

	if enable_debug:
		var debug_text = str(camera_global_position)
		debug_text = debug_text + "\n" + "Game Paused: " + str(Game._pause_state) + "("+str(get_tree().paused)+")"
		debug_text = debug_text + "\n" + "Level loading: " + str(World.level_loading)
		debug_text = debug_text + "\n" + "player input: " + str(!Player.paused)
			#NOTE: this need to change with the new item system. was added with the old to get it working
		#NOTE: may need player or game connect these to signal instead of a direct ref
		if Player.state != null:
			#var player_old_inventory = Player.state.fetch("inventory", "pawn")
			var player_inventory = Player.pawn.inventory.inventory

#			if player_old_inventory != null:
#				debug_text = debug_text + "\n" + "Old Inventory:"
#				for item in player_old_inventory:
#					debug_text = debug_text + "\n" + str(item["meta"]["name"]) + ":"+ str(item["amount"])
			#this will display new inventory items when the system is added.
			#the source currently from the pawn inventory instead of player state
			#(since saving is the last part if adding it)
			if player_inventory != null:
				debug_text = debug_text + "\n" + "Inventory:"
				for item in player_inventory:
					#debug_text = debug_text + "\n" + str(item)
					debug_text = (
						debug_text + "\n" + 
						str(item.get_meta("unique_name",str(item.type.display_name))) +
							"("+str(item.type.display_name)+"):" + 
						str(item.amount)
						)
		debug.text = debug_text
		
		
			#debug.get_canvas_transform().affine_inverse() * debug.get_screen_position()



#func loading(is_loading):
	#await get_tree().create_timer(1).timeout #A delay so things can finish up. currrenty need to be appled difftrently or not used
#	$LoadingScreen.visible = is_loading



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
	ui_focus.emit(
		%Dialog.visible or
		%FishingPondMap.visible or 
		%Main_Menu.visible or 
		%LoadingScreen.visible or
		%Credits_Menu.visible or
		%Options_Menu.visible
	)
		#TODO: have menu objects in one major scene so the lot can have their visibilty
		#changed all at once. That would allow they check only need to check
		#dyanmic elements(fishing and dialog), menu, and loading screen
