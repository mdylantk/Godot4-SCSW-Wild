class_name Game_Handler extends Node2D

@export var game_state : Game_State 
static var game_handler : Game_Handler

signal event_update(event)

#may use propagate_call or nothing since this control all so there little need
#to connect to these
#signal game_start() 
#signal game_end()

func _ready():
	
	event_update.connect(on_event_update)
	
	game_handler = self
	if game_state == null :
		game_state = Game_State.new()
	if game_state.random_seed == 0 :
		randomize()
		game_state.random_seed = randi()
	seed(game_state.random_seed)
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
