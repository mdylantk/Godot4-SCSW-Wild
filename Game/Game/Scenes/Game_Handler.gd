##This handles the game and how it works with the other handlers
##it should freely acess any handlers as long as they do not acess it
##as well as connect to their signals so it can maintain the game loop
class_name Game_Handler extends Node

@export var game_events : Base_Events = preload("uid://by8b1l7earv1n")
#NOTE:this should be listen to signals and triggering events
#so signals are not nessary
#signal event_update(event)
#signal player_created(handler:Node, index : int)

#server may need to be it own handler or a component of this
#this depends if anything but the game will ever need to comunicate with it
#NOTE: can just acess it with % when needed. 
#@onready var server : Node = %Server_Handler

#Note: mostly a concept to allow various pause situaltion stored in one var
#After a certain value, the tree would pause, else only certain systems will be 
#paused
enum Pause_States{
	UNPAUSED = 0,
	GAME_PAUSED = 1 << 1,  #set if the game want to pause the game.
	USER_PAUSED = 1 << 2, #set when the UI want the game paused
	WORLD_PAUSED = 1 << 3, #set when the world want the game paused (or level)
}
#The min value needed to pause the scene tree
const PAUSE_LEVEL : int = Pause_States.GAME_PAUSED
var _pause_state : Pause_States = Pause_States.UNPAUSED:
	set(value):
		_pause_state = value
		handle_pausing()
		
##sets the pause state based on the _pause_state value at the time of it being
##called. This allow the pause logic to run when the setter is not called
##such as the start of the game, this should be called in the _ready
func handle_pausing():
	get_tree().paused = _pause_state >= PAUSE_LEVEL

#func print_copyright():
	#TODO include this in game and test Engine.get_license_info when built
#	print(Engine.get_license_info)
#	print(Engine.get_license_text())

func on_event(id:String, data: Variant):
	#call group if non of the id matches
	#or pass the group id as a part of data
	if id == 'group_call':
		#Note: not sure how to pass args. may be better to have dedicated
		#event objects instead of calling to group for this system
		#in a sence a lot of handler may have a event resource or a state resource
		#for that case. events are connections and states are stateful
		get_tree().call_group(data['group'],data['methood'], data['data'])

func _ready():
	
	game_events.event.connect(on_event)
	#make sure pause logic is done base on the default state
	#else something may be not sync correctly
	handle_pausing()
	
	#NOTE: connect to other handler signals to maintain game flow
	#since game handler should know all, but none should directly acess it
	World.level_ready.connect(on_level_ready) #level is ready for game logic
	World.level_busy.connect(on_level_busy) #level is still loading up
	
	
	#world connecting is a redirect of that logic so
	#the game do not need to be told to change level. instead the world
	#can call trigger it
	World.level_changing.connect(change_level) #level is about tpo change
	
	UI.ui_focus.connect(on_ui_focus)
	#Connect to Main Menu to game related triggers
	UI.main_menu.pause.connect(on_menu_pause)
	UI.main_menu.resume.connect(on_menu_resume)
	UI.main_menu.new_game.connect(on_new_game)
	UI.main_menu.load_game.connect(on_load_game)
	UI.main_menu.end_game.connect(on_end_game)
	



@rpc("any_peer","call_local")
func start_game(is_new:bool = true, save_name:String="Default"):
	
	#set up the save state, either make sure it new or load from file
	Data.init_save(save_name,!is_new)
	
	#set up at least one persistant seed to use in generators
	#World seed is to help keep the world gen similar or the same between sessions
	var world_seed : int
	if Data.save_state.has_section_key("Game","world_seed"):
		world_seed = Data.save_state.get_value("Game","world_seed",0)
		seed(world_seed)
	else:
		randomize()
		world_seed = randi()
		Data.save_state.set_value("Game","world_seed",world_seed)
		
	#load the maps and assign the seeds. could have a dedicated system
	#to handle this or let the world (or level using world tools) handle it
	var detail_map = load("uid://087vceuyr40g")
	var height_map = load("uid://te65swlvsp53")
	var variation_map = load("uid://cp0b4i2m77i8m")
	detail_map.seed = world_seed
	height_map.seed = world_seed
	variation_map.seed = world_seed
	
	change_level("uid://cldlaymbe77mn")


func end_game(full_quit:bool = false):
	print_debug("ending game")
	if full_quit:
		get_tree().quit()
	#basicly just make sure every system calls an unload
	#and then either shut down or go to mode_selection
	
#Below is the new game change logic
func change_level(uid):
	if OK == get_tree().change_scene_to_file(uid):
		
		if !get_tree().tree_changed.is_connected(on_tree_changed):
			get_tree().tree_changed.connect(on_tree_changed)
		#tell GUI and controllers that the gamplay is loading(disable imput and such)
		World.level_loading = true
	else:
		print_debug("Error, unable to load scene")

func on_tree_changed():
	var level = get_tree().get_current_scene()
	if level != null:
		get_tree().tree_changed.disconnect(on_tree_changed)
		level_changed(level)
		#get_tree().call_group("Players", "reparent_pawn", level)
		World.level_loading = false
		#tell GUI and controllers that the gamplay is may be loaded
		#though the world may need to pass another signal
		#like level_ready. the issue is that there no relibale way
		#to ensure it will be called unless the level is known or a delay 
		#is used to allow the level to tell the world it is loading and to 
		#wait for the okay

#NOTE: below may seem redundent, but both the game and level handles setting the level
#the world could take over the loading of the level, but I wanted the get_tree logic
#to be reserver for the game handler or other 'know it all' systems
##called when world say the level ready. ideally a frame after the level _ready()
##unless the level delay the signal
##should only be called once per level load unless a busy func is added for
##dynamic loading
func on_level_ready():
	UI.loading = false
	_pause_state &= ~Pause_States.WORLD_PAUSED
	pass
##called when level is loading something and need gameplay pause
func on_level_busy():
	UI.loading = true
	_pause_state |= Pause_States.WORLD_PAUSED
	pass
	
#NOTE: this gives the player a character. either one tag in the level
#or a fix one provided here(or another handler)
func level_changed(new_level:Node):
	print_debug("level changed: ", new_level)
	#NOTE: below was to regester a pawn, but may use brain or something similar
	#to directly assign itself
	#for child:Node in new_level.get_children():
	#	if child.is_in_group("player"):
	#		print_debug("player found")
	#		Player.pawn = child
	#		break
	

#NOTE: UI may not need to have it input paused here. it can, but
#it should be handling it within in itself. The player is a specail case
#where UI way need to limited pause the game where world base input is disable
#Also may be able to flat disbale unprocess input, but that still need to be handled here
#UI (new) Listerners
##toggles if the player input need to be paused or not
func on_ui_focus(pause_input:bool = true)->void:
	print_debug(pause_input)
	#TODO may need a better way. might just pause the game and have some system
	#process. the issue is the character moves, so the direction set need to be reset
	%Player_Handler.paused = pause_input


#MAIN MENU LISTENERS

func on_menu_pause()->void:
	_pause_state |= Pause_States.USER_PAUSED

func on_menu_resume()->void:
	_pause_state &= ~Pause_States.USER_PAUSED
	
func on_new_game(id:String="Default")->void:
	start_game(true, id)
	_pause_state &= ~Pause_States.USER_PAUSED

func on_load_game(id:String="Default")->void:
	start_game(false, id)
	_pause_state &= ~Pause_States.USER_PAUSED
	
func on_end_game()->void:
	#TODO the bool is to quit out completly. either have the menu pass a flag/bool
	#or handle the check here
	end_game(true)
