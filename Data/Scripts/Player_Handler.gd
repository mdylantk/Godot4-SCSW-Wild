class_name Player_Handler extends Node2D

#states the pawn may be in. used mostly in the pawn update signal to let listers know why it was called
#it may or may not be used depending on the pawn lifespand and if the state can be grab from the pawn
enum Pawn_State {Null = -1, Init = 0, Alive, Dead, Respawn}

#todo: add signal like events
signal pawn_update(pawn, state : Pawn_State)
signal interact(handler, instigator, target, data)
#passing state, but might need to pass handler and player idex if system change that way
signal player_meta_changed(player_state, property, old_value)



#note: most logic is set be be single player. multiplayer need to be tested
#and most of the logic gated/ignored if not the client/owner
#Todo: may be able to use one player handler for more than one users depending on the whay godot 
#handle input. if so, some var may become arrays or moved into playerstate and player state turn into an array
@export var state : Player_State

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

func get_hud():
	return $HUD

#this is just to read a signal
func update_test(pawn, state : Pawn_State):
	print(str(pawn) + ' ' + str(state))


func _ready():
	#this is to test the signal
	pawn_update.connect(update_test)
	player_meta_changed.connect(player_meta_changed_test)
	
	if state == null :
		state = Player_State.new() 
		#this also could be where loading state happens if state is created when player 'joins'
	if pawn == null:
		pawn_state = Pawn_State.Null
		if has_node("Player"):
			pawn = $Player
			pawn_state = Pawn_State.Init
			#set pawn to $player if it exist
			#good for testing and automatic set up,
			#but a function should be called instead
		else:
			var pawn_ref = load(default_pawn).instantiate()
			add_child(pawn_ref)
			pawn_ref.name = "Player" #todo: make child of world main scene for objects
			pawn = pawn_ref
	pawn_state = Pawn_State.Alive
	#on_transfer()
	pawn.inventory.slot_update.connect(on_item_gain)

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
			

#TODO: maybe use unhandle_Input(unless that for ui). also see if user id is an option
#Also maybe see if it should emit a signal on vaild actions(kind of like with interact. accept/cancel 
#may be an option, but might be vauge on it own if nothing happen beside input)
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
						var event_data = {}
						interact.emit(self, pawn, result["collider"], event_data)
						#print("reg event end")
						if(event_data.has("canceled")):
							print("on_interact was canceled")
						else:
							result["collider"].on_interact(self, pawn, result["collider"], event_data)
			#pawn.inventory.add_item(Item.new_item(Item, 10))
			#print(pawn.inventory.items)
		#elif event.is_action("Cancel") && event.is_action_pressed("Cancel"):
			#pawn.inventory.add_item(Item.new_item(Item, -5))
			#print(pawn.inventory.items)

func on_item_gain(inventory, slot, old_item):
	#could leave this and just properly connect/disconnect on pawn change
	#the could check the new slot data
	#and if diffrent, run some logic like check if have fish name and of what
	#issue if the fish name is not added to item, the the fish logic would need to 
	#interact with the handler(like it kind of doing now) to do the check
	#NOTE: Big issue is that score is update when unable to store fish
	#but a check with the return value should fix that
	print("inv: "+ str(inventory))
	print("slot: "+ str(slot))
	print("old: "+ str(old_item))
	print("new: "+ str(inventory.items[slot]))

func set_player_meta(property, value):
	var old_value = get_player_meta(property)
	state.metadata[property] = value
	player_meta_changed.emit(state, property, old_value)
func get_player_meta(property):
	if (state.metadata.has(property)):
		return state.metadata[property]
	return null
	
func player_meta_changed_test(player_state, property, old_value):
	print("state: "+ str(player_state))
	print("property: "+ str(property))
	print("old_value: "+ str(old_value))