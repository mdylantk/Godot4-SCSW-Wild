class_name Game_Handler extends Node2D

@export var state : Game_State 
#todo, try to have this autoload instead of static ref. maybe use a auroload scrip only to get this ref
#static var game : Game_Handler #todo change to game
@export_file("*.tscn") var default_world_handler : \
	String = "res://Data/Scenes/Handlers/World_Handler.tscn"
@export_file("*.tscn") var default_player_handler : \
	String = "res://Data/Scenes/Handlers/Player_Handler.tscn"

signal event_update(event)

#may use propagate_call or nothing since this control all so there little need
#to connect to these
#signal game_start() 
#signal game_end()
func get_player(index : int = 0):
	if has_node("Player_Handler"+str(index)):
		return get_node("Player_Handler"+str(index))
	else:
		return null
	#todo: add logic for other player handlers
func get_world():
	if has_node("World_Handler"):
		return $World_Handler
	else:
		return load_world()

func get_seed() -> int :
	return state.random_seed

func load_world():
	if !has_node("World_Handler"):
		var world = load(default_world_handler).instantiate()
		world.name = "World_Handler"
		add_child(world)
		return world
		
func load_player(index : int = 0):
	if !has_node("Player_Handler"+str(index)):
		var player = load(default_player_handler).instantiate()
		player.name = "Player_Handler"+str(index)
		add_child(player)
		return player
#func _init():
#	load_world()
#	load_player()
	
func _ready():
	load_world()
	load_player()
	event_update.connect(on_event_update)
	
	#game = self
	if state == null :
		state = Game_State.new()
	if state.random_seed == 0 :
		randomize()
		state.random_seed = randi()
	seed(state.random_seed)
	get_world().level_data.seed_maps(get_seed())
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

func register_event(event : Event):
	print("event signal start")
	event_update.emit(event)
	print("event signal end")
func on_event_update(event : Event):
	print(str(event))
	if event != null:
		print("event update")
		event.end_event()
