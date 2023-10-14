class_name Player_Handler extends Node2D

#states the pawn may be in. used mostly in the pawn update signal to let listers know why it was called
#it may or may not be used depending on the pawn lifespand and if the state can be grab from the pawn
enum Pawn_State {Null = -1, Init = 0, Alive, Dead, Respawn}

#todo: add signal like events
signal pawn_update(pawn, state : Pawn_State)
#signal item_pickup(item)#should this be here? 
#actors may pick item up, but controllers are the ones that grab items
#also actors have inventoory that not stored in player state (untill save)
#proabaly a group call to game which player handler can listen to
#wonder if a event resource could help compact data?...or maybe crate the instance
#anf game just keep tract of active events



#note: most logic is set be be single player. multiplayer need to be tested
#and most of the logic gated/ignored if not the client
@export var player_state : Player_State

#todo: have this load a pawn if pawn null. also figure out hoe to get a spawn location from world
#and if world or tilemap should hold pawb ref
@export_file("*.tscn") var default_pawn = "res://Data/Scenes/Actors/Player.tscn"

var pawn #pawn may be move around, so a direct ref will be used to track it
var uid = 0 #may or may not be needed if there a built in way to get a user id

#
#this may not be useful, but here as a way to change state and update
#the state do not need to be known, just when something happen, the signal need to emit
var pawn_state: Pawn_State :
	set(value):
		pawn_state = value
		pawn_update.emit(pawn, pawn_state)
	get:
		return pawn_state

#this is just to read a signal
func update_test(pawn, state : Pawn_State):
	print(str(pawn) + ' ' + str(state))


func _ready():
	#this is to test the signal
	pawn_update.connect(update_test)
	
	if player_state == null :
		player_state = Player_State.new() 
		#this also could be where loading state happens if state is created when player 'joins'
	if pawn == null:
		pawn_state = Pawn_State.Null
		if $Player != null:
			pawn = $Player
			pawn_state = Pawn_State.Init
			#set pawn to $player if it exist
			#good for testing and automatic set up,
			#but a function should be called instead
	pawn_state = Pawn_State.Alive
	#on_transfer()

func _physics_process(_delta) :
	#Note: need to locate use_input what setting it (most likly world handler) and instead link it here
	if pawn != null:
		var input_dir = Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
		pawn.move(input_dir)
		
		#probably should do the old way and register pawn as a loader
		get_tree().call_group("World_Handler", "load_chunks", pawn.global_position)

func chunk_update(pos,length,is_loaded):
	#print("chunk ready: " + str(is_loaded) + " " + str(pos) + " | size :" + str(length))
	if is_loaded:
		#if loaded and chunk player is in, then trun off loading screen
		#may need a menu flag, but mostly just need to disable most input when loading
		if (pawn.global_position/length).round() == pos : #(pos/length).round():
			get_tree().call_group("HUD", "loading", false)
	else:
		#if chunk pawn in is not loaded, enable loading screen
		if (pawn.global_position/length).round() == pos : #(pos/length).round():
			get_tree().call_group("HUD", "loading", true)
			pass
			

func _input(event) :
	#NOTE: facing direction is being ref here, and if pawn lacks it, it could be a problem
	#may need to make sure all pawns have it or find an indirect way to get a value
	#but it is in the base pawn movement so it may be fine for now
	#NOTEL: this came from player.any location or ref to self should be for pawn unless new
	if pawn != null :
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
						print("create event")
						var on_interact_event = Generic_Event.new(self,"Event",pawn, result["collider"],{"result":result})
						#if is_cancel = true, then it cancel as log as the check is here. 
						#but probably should pass the event on on_interact and maybe catch it
						#so it can be modify/process there and pawn can wait for the event to end
						on_interact_event.event_finished.connect(on_event_end)
						#NOTE!!! no need to reg events. as long as even_end is called and
						#the source listen to event_finished, then everything should work
						#also would neeed to pass event to other things(but a listener for event
						#would be called). alsoa need to store event in array or var if lifetime
						#ever neeed to extend a tick
						print("reg event start")
						Game_Handler.game_handler.register_event(on_interact_event)
						print("reg event end")
						if(!on_interact_event.is_canceled):
							#result["collider"].on_interact(pawn)
							print("event logic start")
							result["collider"].on_interact(on_interact_event)
							print("event logic end")
			print(str(pawn.inventory.add_item(Item.new_item(Item, 33))))
			print(pawn.inventory.items)
		if event.is_action("Cancel") && event.is_action_pressed("Cancel"):
			print(str(pawn.inventory.add_item(Item.new_item(Item, -1))))
			print(pawn.inventory.items)
func on_event_end(event):
	if event != null:
		print("event ending")
	pass
