class_name Game_Handler extends Node2D

@export var state : Game_State 
#todo, try to have this autoload instead of static ref. maybe use a auroload scrip only to get this ref
#static var game : Game_Handler #todo change to game
@export_file("*.tscn") var default_player_handler : \
	String = "res://Data/Scenes/Handlers/Player_Handler.tscn"
	
#note: this might not have signals, but instead link all the handler signals
#here or something similar
signal event_update(event)

##Core Handlers
@onready var hud : Node = %HUD
@onready var input : Node = %Input_Handler
@onready var world : Node = %World_Handler
@onready var server : Node = %Server_Handler



func get_player_handler(index : int = 0):
	#todo, if index -1, maybe get the owning player?
	#NOTE: player_handler could also be a resource if nessary, but a node may be easier
	if has_node("Player_Handler"+str(index)):
		return get_node("Player_Handler"+str(index))
	else:
		return null
 
func get_seed() -> int :
	return state.random_seed
		
func load_player_handler(index : int = 0):
	if !has_node("Player_Handler"+str(index)):
		var player = load(default_player_handler).instantiate()
		player.name = "Player_Handler"+str(index)
		add_child(player)
		#TODO may be best to pass the pawn to the world handler
		#so the world can check the pos instead of a redundent tick link
		#player.world = get_world_handler()
		if index == 0: #TODO: need to make sure the correct client get link to hud
		#else hud input will be all mess up. will limit to the host controller atm
			#TODO: maybe design it so the hud know the player, but the player do not
			#would require Game.HUD to call gui events like notify
			hud.player_handler = player
			input.player_handler = player
		return player

#a way to get play index without storing it in a var
#for cases where uid is not currently being used
func get_player_handler_index(player):
	return player.name.split("Player_Handler")[1]
	
#func _init():
#	load_world()
#	load_player()

### General game events ###
func change_level(level, handler):
	world.change_level(level,handler)
	hud.loading = true

#client side for the most part. just need to have events trigger in it rep if nessary
func start_dialog(dialog_data):
	hud.gui_dialog.open_dialog(dialog_data)

#client side, but server should be able to send messages
func send_notifcation(message : String):
	hud.gui_notify.add_notify_message("[center]"+message)

#client side, but what call it may or may not need rep
func allow_input(use_input:bool = true):
	input.enable_input = use_input


func print_copyright():
	#TODO include this in game and test Engine.get_license_info when built
	print(Engine.get_license_info)
	print(Engine.get_license_text())

func _ready():
	load_player_handler()
#	event_update.connect(on_event_update)
	
	#print_debug(get_player_handler_index(get_player_handler()))
	
	#game = self
	if state == null :
		state = Game_State.new()
	if state.random_seed == 0 :
		randomize()
		state.random_seed = randi()
	seed(state.random_seed)
	world.level_data.seed_maps(get_seed())
	
	start_game.rpc()
	#TODO: learn how to seed properly so same seed will generate same world


@rpc("any_peer","call_local")
func start_game():
	#the idea is there at least a main menu in the future
	#start game would init the world. before that there may be game
	#config or waiting for players
	#for testing, player may start game as a host but can join someone elses
	#game. just need a way to end the host status 
	pass
func end_game():
	#basicly just make sure every system calls an unload
	#and then either shut down or go to mode_selection
	pass


