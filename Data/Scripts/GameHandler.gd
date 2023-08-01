class_name Game_Handler extends Node2D

#NOTE: since random seed is set here (and this is game) this should be created first
#then its children. if it not done so nativly, it would need to be forced.


#NOTE: signals are said to be low to high...but the issue is handlers are far apart
#basicly could have the signal here and point down to the others
#then only this is nessary to know about
#or do that in global. basicly any global get_ could(and probablys should) be turn
#into a signal. but first need to deside on what is needed. 
#still do not see the diffrence though, both ways need a ref to the handler 
#but signals need an addital function
#also the children need the signals ans emit it. so this would have to connect.
#i get confused. that little peice with connecting though
#would be easier to set up after having a player spawn in.
#so the player just connects through the player handler or well game handler
#game_handler->create player state->create player. 
#then game can connect state and player to the correct signals?
#also for siblings. basicly hook gui update to signals on player
#like set notify message would be trigger in player signal notify
#just need the upper level to connect to it
#(Seem a bit redundent without knowing the back end well, but lack of interface mean i have to trust signals and groups)

@export var game_state : Game_State 

func _ready():
	if game_state == null :
		game_state = Game_State.new()
	if game_state.random_seed == 0 :
		randomize()
		game_state.random_seed = randi()
		print(game_state.random_seed)
		#set to random seed base on system time. 
		#then generate a storable random number to use as the actual seed
		#NOTE: dose not generate the same so would need to look up how to sync values for same randoms
	print("game_handler loaded")
	seed(game_state.random_seed)

#this is here temp untill game state is design

#this handles most of the game set up logic, load/save, and game var
#it should tell the player handler stuff like when to spawn a pawn or other stuff. simple event like
#functions with limited parameters
#mostly for server regulation and an isolated place to store var about the game

#note:gamestate may be a resources added as a var here for savable data

#redeigning to have the game handler as the main scene since iit be easier to interact with the 
#other handlers if they are children of this
#player may or may not need to be part of world handler.
#that depends on how world handle works. if it for just the world map, player should not be a child
#then instance(specail temp copies of a level) and level(usally static areas in size and content) handlers 
#could come into play to handle diffrent zone types.
#also if either player handle or game handle need to be a type not part of node2d, then player would need
#to be part ofn the world hander or a similar system
