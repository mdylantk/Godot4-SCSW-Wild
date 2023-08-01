class_name Player_Handler extends Node2D

@export var player_state : Player_State

var pawn #this could be get by the node tree, but be faster to store it. 
var uid = 0 #0 for singleplayer. multiplayer would need a way to set this 

func _ready():
	print("player_handler loaded")
	if player_state == null :
		player_state = Player_State.new() 
		#this also could be where loading state happens if state is created when player 'joins'
	if pawn == null:
		if $Player != null:
			pawn = $Player
			#set pawn to $player if it exist
			#good for testing and automatic set up,
			#but a function should be called instead
	print(pawn)

#this node should exist for each player
#it should have client and server functinality replated to the player
#client: input management and general settings
#server: input rep, cserver importiaint plar var rep

#also should have a way to get user id better
#a ref to the player main pawn, viewport, and/or camera

#should handle creating/loading the proper spawn...but may need to listen to game handler for the okay and parametters


#note:playerstate may be a resources added as a var here for savable data

#NOTE!!!this need to be a node2D for it to own it's pawn and work with y sort
