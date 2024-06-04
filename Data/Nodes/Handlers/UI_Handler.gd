class_name UI_Handler extends Node

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
		
@onready var loading : bool = false :
	set(value):
		if(%LoadingScreen):
			%LoadingScreen.visible = value
		if loading != value: #nned these check so state do not get refreshed to an invaild one
			enable_player_input = !value
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

##enable the input for the player controller, else
##player contoller will nopt process the input
@export var enable_player_input : bool = true

@onready var debug : Label = %Debug
@export var enable_debug : bool = true


var player_handler : Player_Handler

#var player_state : Savable_State
#var player_pawn 
#func _ready():
	#pass

func handler_setup(handler):
	#NOTE: GUI may ask for handler or listen for handler, since there little reason
	#for game or anything else to acces HUD. HUD ment to observe all and act like input
	var common_fish_count = Savedata_Helper.fetch_player_score(handler,"common_fish_caught")
	var rare_fish_count = Savedata_Helper.fetch_player_score(handler,"rare_fish_caught")
	%Score.set_common_score(common_fish_count)
	%Score.set_rare_score(rare_fish_count)
	player_handler = handler

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
	
	Game.player_created.connect(on_player_created)

func on_player_created(player:Node, index : int):
	if index == 0: #0 should be host or owning client. may need a better way or a built in way
		player.state.data_changed.connect(on_player_state_change)
		handler_setup(player)

##general gameplay input for player. may need to have player handle this
##directly and pause the player if game is pause or gameplay is paused
func _unhandled_input(event:InputEvent):
	if enable_player_input and player_handler != null: 
		player_handler.input_update(event)
		


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
		
		loading = not (
			World.is_chunk_loaded(camera_global_position + Vector2(320,320)) and
			World.is_chunk_loaded(camera_global_position + Vector2(-320,320)) and
			World.is_chunk_loaded(camera_global_position + Vector2(320,-320)) and
			World.is_chunk_loaded(camera_global_position + Vector2(-320,-320))
				)
		#loading = false
	if enable_debug:
		debug.text = str(camera_global_position)
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
