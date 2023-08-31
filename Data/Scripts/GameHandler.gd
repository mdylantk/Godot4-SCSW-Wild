class_name Game_Handler extends Node2D

@export var game_state : Game_State 

func _ready():
	if game_state == null :
		game_state = Game_State.new()
	if game_state.random_seed == 0 :
		randomize()
		game_state.random_seed = randi()
	seed(game_state.random_seed)
	#TODO: learn how to seed properly so same seed will generate same world
	
