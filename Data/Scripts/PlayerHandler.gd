class_name Player_Handler extends Node2D
enum Transfer_State_Enum {To_Instance = -3, To_World= -2, To_Menu = -1, Init = 0, Menu, World, Instance}

@export var player_state : Player_State

var pawn #this could be get by the node tree, but be faster to store it. 
var uid = 0 #0 for singleplayer. multiplayer would need a way to set this

#@export_enum("Init", "Menu", "World", "Instance") var transfer_state: int
var transfer_state: Transfer_State_Enum :
	set(value):
		transfer_state = value
		on_transfer()
	get:
		return transfer_state


#TODO: move input logic here and tell pawn to move in a way an an ai would tell a pawn to move

#TODO: may need to move player pawn to be a child of world handler and instance handler
#player stat should maintain the ref and link it. then get_parent could be used to see what state is
#handling it. just need to rename player to represent the controller index
func on_transfer():
	#print("meow: ")
	#print(str(transfer_state))
	if transfer_state == Transfer_State_Enum.Init:
		get_tree().call_group("HUD", "loading", true)
		#print(str(Transfer_State_Enum.Init))
		transfer_state = Transfer_State_Enum.To_World
	elif transfer_state == Transfer_State_Enum.To_Menu:
		get_tree().call_group("HUD", "loading", false) #may need to seta state. loading and menu would be diffrent states
		#print(str(Transfer_State_Enum.To_Menu))
		transfer_state = abs(transfer_state)
		pass
	elif transfer_state == Transfer_State_Enum.To_World:
		get_tree().call_group("HUD", "loading", true)
		var active_chunk = Global.get_world_handler().get_current_chunk(pawn.global_position)
		if active_chunk != null:
			if active_chunk.is_ready:
				var world_ref = Global.get_world_handler()
				if Global.change_parents(pawn, world_ref):
					#transfer_state = abs(transfer_state)
					pass
				else:
					print_debug("something is null")
		pass
	elif transfer_state == Transfer_State_Enum.To_Instance:
		get_tree().call_group("HUD", "loading", true)
		var instance_ref = Global.get_instance_handler()
		
		if Global.change_parents(pawn, instance_ref):
		#print(str(Transfer_State_Enum.To_Instance))
			transfer_state = abs(transfer_state)
		else:
			print_debug("something is null")
		pass
	else:
		get_tree().call_group("HUD", "loading", false)
#a general way to toggle state changes. (@export for test, sould not be needed)
#the point is to toggle state change. negative values are unusal states that only temporary
#0 is default and will try to push to a positive value. 
#positive state are more perment states saying where it is. 
#menu indicate input being paused except for menu stuff. world may pause or will be hidden to player
#world is stating player is in the world levels. main purpous is to run the transfer logic, but could do others if needed
#change transfer states to negatives. negative vaues now transfer version of positive
#if enum allow math, this should make updating it easier since on end, abs state(unless 0, which need to chouse a positive state to transfer to)



func _ready():
	#print("player_handler loaded")
	if player_state == null :
		player_state = Player_State.new() 
		#this also could be where loading state happens if state is created when player 'joins'
	if pawn == null:
		if $Player != null:
			pawn = $Player
			#set pawn to $player if it exist
			#good for testing and automatic set up,
			#but a function should be called instead
	#print(pawn)
	on_transfer() #if this no long get called for all on process, then this may need to be called here
#this node should exist for each player
#it should have client and server functinality replated to the player
#client: input management and general settings
#server: input rep, cserver importiaint plar var rep

#NOTE!!!this need to be a node2D for it to own it's pawn and work with y sort
func _physics_process(_delta) :
	#Note: need to locate use_input what setting it (most likly world handler) and instead link it here
	if pawn != null:
		if transfer_state > Transfer_State_Enum.Menu:
			var input_dir = Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
			pawn.move(input_dir)
		#on_transfer()#calling this all frames may not be ideal. for now it here untill all
		#states are are know if they need to be check often or is waiting on a change
		
		#below logic that need to be translated to work here
		#var active_chunk = Global.get_world_handler().get_current_chunk(global_position)
		#if active_chunk != null:
		#	use_input = active_chunk.is_ready
func chunk_ready(pos,length):
	print("chunk ready: " + str(pos) + " | size :" + str(length))
	if transfer_state == Transfer_State_Enum.To_World:
		if (pawn.global_position/length).round() == (pos/length).round():
			print(str((pawn.global_position/length).round()))
			print(str((pawn.global_position/length).round()))
			transfer_state = Transfer_State_Enum.World
			print(str(transfer_state))
			#this might fail if it ready before player is ready
			#need to connect the hud since the loading screen probably still using the old data
