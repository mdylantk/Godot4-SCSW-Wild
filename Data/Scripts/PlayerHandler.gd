class_name Player_Handler extends Node2D
#NOTE: since pawn may switch world/instance handler, this may not need to be a node2d
enum Transfer_State_Enum {To_Instance = -3, To_World= -2, To_Menu = -1, Init = 0, Menu, World, Instance}

#note: most logic is set be be single player. multiplayer need to be tested
#and most of the logic gated/ignored if not the client
@export var player_state : Player_State

var pawn #pawn may be move around, so a direct ref will be used to track it
var uid = 0 #may or may not be needed if there a built in way to get a user id

var transfer_state: Transfer_State_Enum :
	set(value):
		transfer_state = value
		on_transfer()
	get:
		return transfer_state

func on_transfer():
	if transfer_state == Transfer_State_Enum.Init:
		get_tree().call_group("HUD", "loading", true)
		transfer_state = Transfer_State_Enum.To_World
	elif transfer_state == Transfer_State_Enum.To_Menu:
		#may need to use state and not a flag. for now this will disable loading since it not needed here
		get_tree().call_group("HUD", "loading", false) 
		transfer_state = abs(transfer_state)
	elif transfer_state == Transfer_State_Enum.To_World:
		get_tree().call_group("HUD", "loading", true)
		#var active_chunk = Global.get_world_handler().get_current_chunk(pawn.global_position)
		#if active_chunk != null:
			#if active_chunk.is_ready:
				#var world_ref = Global.get_world_handler()
				#if Global.change_parents(pawn, world_ref):
				#	print_debug("transfer player to world")
				#else:
				#	print_debug("something is null")
		pass
	elif transfer_state == Transfer_State_Enum.To_Instance:
		#TODO: this logic is not tested and not finish. should
		#be treated like world handler
		get_tree().call_group("HUD", "loading", true)
		var instance_ref = Global.get_instance_handler()
		if Global.change_parents(pawn, instance_ref):
			print_debug("transfer player to instance")
			transfer_state = abs(transfer_state)
		else:
			print_debug("something is null")
	else:
		get_tree().call_group("HUD", "loading", false)

func _ready():
	if player_state == null :
		player_state = Player_State.new() 
		#this also could be where loading state happens if state is created when player 'joins'
	if pawn == null:
		if $Player != null:
			pawn = $Player
			#set pawn to $player if it exist
			#good for testing and automatic set up,
			#but a function should be called instead
	on_transfer()

func _physics_process(_delta) :
	#Note: need to locate use_input what setting it (most likly world handler) and instead link it here
	if pawn != null:
		if transfer_state > Transfer_State_Enum.Menu:
			var input_dir = Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
			pawn.move(input_dir)
		#the player will be like a chunk loader
		#so will push player location to the world handler or similar
		#but may need to limit it for when the player moved and not idle
		if transfer_state == Transfer_State_Enum.World || transfer_state == Transfer_State_Enum.To_World:
			get_tree().call_group("World_Handler", "load_chunks", pawn.global_position)

func chunk_update(pos,length,is_loaded):
	#print("chunk ready: " + str(is_loaded) + " " + str(pos) + " | size :" + str(length))
	if is_loaded:
		if transfer_state == Transfer_State_Enum.To_World:
			if (pawn.global_position/length).round() == pos : #(pos/length).round():
				transfer_state = Transfer_State_Enum.World
				#this might fail if it ready before player is ready
				#need to connect the hud since the loading screen probably still using the old data
	else:
		#this seem to be slow at being called? 
		#print_debug(str((pawn.global_position/length).round()) + " == " + str(pos))
		if (pawn.global_position/length).round() == pos : #(pos/length).round():
			transfer_state = Transfer_State_Enum.To_World
			

func _input(event) :
	#NOTE: facing direction is being ref here, and if pawn lacks it, it could be a problem
	#may need to make sure all pawns have it or find an indirect way to get a value
	#but it is in the base pawn movement so it may be fine for now
	#NOTEL: this came from player.any location or ref to self should be for pawn unless new
	if pawn != null && transfer_state > Transfer_State_Enum.Menu:
		if event.is_action("Accept") && event.is_action_pressed("Accept"):		
			var space_state = get_world_2d().direct_space_state #can get a lot just with the player
			# use global coordinates, not local to node
			var query = PhysicsRayQueryParameters2D.create(
				pawn.global_position, 
				pawn.global_position+(pawn.facing_dirction*24),
				0b10000000_00000000_00000000_00000001, #last is 1, first is 32
				[pawn])
			#0b10000000_00000000_00000000_00001101
			#query.exclude = [local_player]
			var result = space_state.intersect_ray(query)
			if "collider" in result:
				if result["collider"] is TileMap :
					#below test for tilemap data. keeping for now so it be easier to
					#set up a tile base interaction system like search/forage/look/chop
					#print(result["rid"])
					#print(result["collider"].get_coords_for_body_rid(result["rid"]))
					#print(result["collider"].get_layer_for_body_rid(result["rid"]))
					#print(result["collider"].get_cell_tile_data(
					#	result["collider"].get_layer_for_body_rid(result["rid"]),
					#	result["collider"].get_coords_for_body_rid(result["rid"])
					#))
					pass
				else:
					if result["collider"].has_method("on_interact"):
						result["collider"].on_interact(pawn)
