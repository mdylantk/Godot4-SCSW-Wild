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
		player.pawn_update.connect(on_pawn_update)
		return player

#a way to get play index without storing it in a var
#for cases where uid is not currently being used
func get_player_handler_index(player):
	return player.name.split("Player_Handler")[1]
	
#func _init():
#	load_world()
#	load_player()

#note on player interaction for new system:
#player handler should have signal just incase additional logic is needed
#player probably should try to run an interact call after a vaild check with
#the object it is interacting with (currently should be doing that)
#start an interactive state of which either the handler or pawn can handler. handler should be the fall back logic
#interaction should return a dict or list of data needed for the interaction so the player handler can handle it
#authorty is chack via the server side of these nodes
#in short the player handler would handler logic cases for interaction and the pawns will provide the vaild data
#this logic can be provided by static function libaray and the pawn may have overrides or callables
	
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

#decide to use this and have a timer for reacurring events or just use static signals
#func register_event(event : Event):
#	print("event signal start")
#	event_update.emit(event)
#	print("event signal end")
#func on_event_update(event : Event):
#	print(str(event))
#	if event != null:
#		print("event update")
#		event.end_event()

func _process(_delta) :
	#check if chunk is loaded(which also will load it if not
	#should be move to a pawn location change signal or something
	#that do not run per frame. also need a multi client soultion
	#var pawn_location = get_player_handler().pawn.global_position
	#if not is_world_loading(pawn_location):
	pass
		#print(pawn_location)
		#print(false)
func on_pawn_update(handler):
	#currently tell the work the player location
	#as well as check if the chunk/area is loaded or not
	var is_loading = is_world_loading(handler.pawn.global_position,true)
	handler.get_hud().loading = is_loading
	#if is_loading:
		#print_debug("loading chunk")
	#print(pawn.global_position)
###GAME Active STATES###

#this not used yet
#what needs to be done is to tell players if the world at their location is loaded
#ideally when they move or they send a signal asking for an update.
#current sytem use groups as well as load chunk
#so would also need to request that the world load that chunk if it not already
func is_world_loading(location, load = true):
	#invert the bool to match the naming
	return not get_world_handler().is_chunk_loaded(location, load)
	#return false
	
