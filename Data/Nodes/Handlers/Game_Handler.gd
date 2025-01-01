class_name Game_Handler extends Node2D

#NEW NOTE and TODO: ignore below, this should init game and maintain game loop
#nothing should acess this handler normally and this handler should listen 
#to other handler to trigger events.
#NOTE: making most handlers autoload. this will handle running the game
#mostly spawning players and AI as well as act like glue to the other handlers

#TODO: need to handle pause in a non invasive way. currently it is fine,
#but moving pasuing here may cause issues if freeze states are not kept track of
#current world loading can be check in world. can also do the same with UI
#that just means that instead of freezing input when there is change, verify
#that the change also reflects the input state. if world finish loading, but
#game menu is up, then do not unpause player handler input. same the other way around

#TODO INPUT when new level is loaded, have this tell the controllers to pause their
#inputs. GUI would be set to a loading mode so it can decide on what input to allow


@export var state : Savable_State 
#todo, try to have this autoload instead of static ref. maybe use a auroload scrip only to get this ref
#static var game : Game_Handler #todo change to game
#@export_file("*.tscn") var default_player_handler : \
#	String = "res://Data/Nodes/Handlers/Player_Handler.tscn"
#@export var default_player_handler : PackedScene = load("uid://bdpv2nuo5qsqg")
#PackedScene may be better? 
	
#note: this might not have signals, but instead link all the handler signals
#here or something similar
signal event_update(event)
signal player_created(handler:Node, index : int)

##Core Handlers
#@onready var hud = Hud #NOTE:TODO Hud should call Game and listen to Game. Game should run without knowing abut HUD
#@onready var input : Node = %Input_Handler
#@onready var world : Node = %World_Handler
@onready var server : Node = %Server_Handler

func get_player_handler(index : int = 0):
	if Player != null and index == 0:
		return Player
	#todo, if index -1, maybe get the owning player?
	#NOTE: player_handler could also be a resource if nessary, but a node may be easier
	if has_node("Player_Handler"+str(index)):
		return get_node("Player_Handler"+str(index))
	else:
		return null
 
func get_seed() -> int :
	return state.random_seed
		
func load_player_handler(index : int = 0):
	if Player != null:
		Player.setup()
		Player.state.data_changed.connect(UI.on_player_state_change)
		UI.handler_setup()
		return
	#if !has_node("Player_Handler"+str(index)):
		#var player = default_player_handler.instantiate()
		#player.name = "Player_Handler"+str(index)
		#add_child(player)
		#TODO may be best to pass the pawn to the world handler
		#so the world can check the pos instead of a redundent tick link
		#player.world = get_world_handler()
		#if index == 0: #TODO: need to make sure the correct client get link to hud
		#else hud input will be all mess up. will limit to the host controller atm
			#TODO: maybe design it so the hud know the player, but the player do not
			#would require Game.HUD to call gui events like notify
			#hud.player_handler = player
			#UI.player_handler = player
			#player.state.data_changed.connect(hud.on_player_state_change)
			#hud.handler_setup(player)
			#pass
		#player_created.emit(player,index)
		#return player

#a way to get play index without storing it in a var
#for cases where uid is not currently being used
func get_player_handler_index(player):
	if player == Player:
		return 0
	return player.name.split("Player_Handler")[1]
	
#func _init():
#	load_world()
#	load_player()

### General game events ###
#func change_level(level, handler):
#	World.change_level(level,handler)
	#hud.loading = true

#client side for the most part. just need to have events trigger in it rep if nessary
#func start_dialog(dialog_data):
#	hud.gui_dialog.open_dialog(dialog_data)

#client side, but server should be able to send messages
#func send_notifcation(message : String):
#	hud.gui_notify.add_notify_message("[center]"+message)

#client side, but what call it may or may not need rep
#func allow_input(use_input:bool = true):
#	UI.enable_input = use_input


func print_copyright():
	#TODO include this in game and test Engine.get_license_info when built
	print(Engine.get_license_info)
	print(Engine.get_license_text())

func _ready():
#	event_update.connect(on_event_update)
	
	#print_debug(get_player_handler_index(get_player_handler()))
	
	#game = self
	if state == null :
		state = Game_State.new()
		state.file_name = "game_state"
	if state.random_seed == 0 :
		randomize()
		state.random_seed = randi()
	seed(state.random_seed)
	#world.level_data.seed_maps(get_seed())
	#TODO: have a handler for semi static resource
	#and update the seeds from a save state
	#TODO: the world probably should handle this
	#or a resource manager
	var detail_map = load("uid://087vceuyr40g")
	var height_map = load("uid://te65swlvsp53")
	var variation_map = load("uid://cp0b4i2m77i8m")
	detail_map.seed = state.random_seed
	height_map.seed = state.random_seed
	variation_map.seed = state.random_seed
	
	#start_game.rpc()
	#TODO: learn how to seed properly so same seed will generate same world
	
	#NOTE: connect to other handler signals to maintain game flow
	#since game handler should know all, but none should directly acess it
	World.level_ready.connect(on_level_ready)
	World.level_busy.connect(on_level_busy)
	
	
	#world connecting is a redirect of that logic so
	#the game do not need to be told to change level. instead the world
	#can call trigger it
	World.level_changing.connect(change_level)
	


@rpc("any_peer","call_local")
func start_game(is_new:bool = true, save_name:String="Default"):
	#Resources.current_save_name = save_name
	Data.init_save(save_name,!is_new)
	#if is_new:
	#	var path:String = Resources.get_save_path(false)
	#	if DirAccess.dir_exists_absolute(path):
	#		var dir:DirAccess = DirAccess.open(path)
	#		for file in dir.get_files():
				#will only remove files that is consider save files. this may need to be expanded on
				#also may need to move this logic to the resource handler
	#			if file.contains(".data") or file.contains(".cfg") or file.contains(".tres"):
	#				dir.remove(file)
	#		DirAccess.remove_absolute(path)
	
	load_player_handler()
	#World.level_data = load("uid://cvna13cf6rc1p")
	
	
	#await get_tree().process_frame
	change_level("uid://cldlaymbe77mn")
	
	
	#World.load_level("uid://cldlaymbe77mn")
	
	#the idea is there at least a main menu in the future
	#start game would init the world. before that there may be game
	#config or waiting for players
	#for testing, player may start game as a host but can join someone elses
	#game. just need a way to end the host status 
	pass

func end_game(full_quit:bool = false):
	print_debug("ending game")
	if full_quit:
		get_tree().quit()
	#basicly just make sure every system calls an unload
	#and then either shut down or go to mode_selection
	
#Below is the new game change logic
func change_level(uid):
	if OK == get_tree().change_scene_to_file(uid):
		#NOTE: will move player pawns to game for now untill a reusable
		#player pawn is made to be added as needed in levels instead of 
		#reparenting
		get_tree().call_group("Players", "reparent_pawn", self)
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
		get_tree().call_group("Players", "reparent_pawn", level)
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
	pass
##called when level is loading something and need gameplay pause
func on_level_busy():
	UI.loading = true
	pass
	
#NOTE: this gives the player a character. either one tag in the level
#or a fix one provided here(or another handler)
func level_changed(new_level:Node):
	print_debug("level changed")
	#NOTE: below was to regester a pawn, but may use brain or something similar
	#to directly assign itself
	#for child:Node in new_level.get_children():
	#	if child.is_in_group("player"):
	#		print_debug("player found")
	#		Player.pawn = child
	#		break
