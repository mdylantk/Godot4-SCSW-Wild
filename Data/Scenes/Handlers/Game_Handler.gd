class_name Game_Handler extends Node2D

@export var state : Game_State 
#todo, try to have this autoload instead of static ref. maybe use a auroload scrip only to get this ref
#static var game : Game_Handler #todo change to game
@export_file("*.tscn") var default_world_handler : \
	String = "res://Data/Scenes/Handlers/World_Handler.tscn"
@export_file("*.tscn") var default_player_handler : \
	String = "res://Data/Scenes/Handlers/Player_Handler.tscn"

signal event_update(event)

#TODO: make this handle all game logic. whengame start to when game ends.
#also handle start scene is an option if this do not need to be autoload
#once ready, game logic start. most of it will listen to the other handler
#but may need a game loop or something similar.


#may use propagate_call or nothing since this control all so there little need
#to connect to these
#signal game_start() 
#signal game_end()
func get_player_handler(index : int = 0):
	if has_node("Player_Handler"+str(index)):
		return get_node("Player_Handler"+str(index))
	else:
		return null
	#todo: add logic for other player handlers

func get_world_handler():
	if has_node("World_Handler"):
		return $World_Handler
	else:
		return load_world_handler()

func get_seed() -> int :
	return state.random_seed

func load_world_handler():
	if !has_node("World_Handler"):
		var world = load(default_world_handler).instantiate()
		world.name = "World_Handler"
		add_child(world)
		return world
		
func load_player_handler(index : int = 0):
	if !has_node("Player_Handler"+str(index)):
		var player = load(default_player_handler).instantiate()
		player.name = "Player_Handler"+str(index)
		add_child(player)
		#TODO may be best to pass the pawn to the world handler
		#so the world can check the pos instead of a redundent tick link
		player.world = get_world_handler()
		return player

#a way to get play index without storing it in a var
#for cases where uid is not currently being used
func get_player_handler_index(player):
	return player.name.split("Player_Handler")[1]
	
#func _init():
#	load_world()
#	load_player()

func print_copyright():
	#TODO include this in game and test Engine.get_license_info when built
	print(Engine.get_license_info)
	print(Engine.get_license_text())

func _ready():
	load_world_handler()
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
	get_world_handler().level_data.seed_maps(get_seed())
	#TODO: learn how to seed properly so same seed will generate same world

#todo: add func for states for loading up a game so things comunicate better
#akso decide if game handle could change or a game mode object will be used
func on_mode_selection():
	#when the game starts or ends, this would call the logic for setting up
	#the main menu and unloading everything else if there was a game loaded
	pass
func on_game_start():
	#load player
	#prep the spawn map(bare min gen)
	#spawn pawn in spawn map
	#finish spawn map gen and any
	#give control to player and show screen
	pass
func on_game_end():
	#basicly just make sure every system calls an unload
	#and then either shut down or go to mode_selection
	pass


