class_name Game_Handler extends Node2D

#NOTE: since random seed is set here (and this is game) this should be created first
#then its children. if it not done so nativly, it would need to be forced.


@export var game_state : Game_State 

func _ready():
	if game_state == null :
		game_state = Game_State.new()
	if game_state.random_seed == 0 :
		randomize()
		game_state.random_seed = randi()
		#print(game_state.random_seed)
		#set to random seed base on system time. 
		#then generate a storable random number to use as the actual seed
		#NOTE: dose not generate the same so would need to look up how to sync values for same randoms
	#print("game_handler loaded")
	seed(game_state.random_seed)
	


