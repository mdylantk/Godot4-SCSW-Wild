class_name Player_Handler extends Node2D

#states the pawn may be in. used mostly in the pawn update signal to let listers know why it was called
#it may or may not be used depending on the pawn lifespand and if the state can be grab from the pawn
#enum Pawn_State {Null = -1, Init = 0, Alive, Dead, Respawn}


#sent when there is a change in pawn movement
#signal pawn_update(handler)

signal interact(handler, instigator, target, data)
#passing state, but might need to pass handler and player idex if system change that way
#signal player_meta_changed(player_state, property, old_value)


#note: most logic is set be be single player. multiplayer need to be tested
#and most of the logic gated/ignored if not the client/owner
#Todo: may be able to use one player handler for more than one users depending on the whay godot 
#handle input. if so, some var may become arrays or moved into playerstate and player state turn into an array
@export var state : Player_State

#todo: have this load a pawn if pawn null. also figure out hoe to get a spawn location from world
#and if world or tilemap should hold pawb ref
@export_file("*.tscn") var default_pawn = "res://Data/Scenes/Actors/Player.tscn"

var pawn #pawn may be move around, so a direct ref will be used to track it
var uid = 0 #may or may not be needed if there a built in way to get a user id\

#this is the world ref so the handler can run without casting up
#when working with its sibling. NOTE: level changes may cause bugs
#so need a way to make sure actions are not queued at level transfer
#(like try not to use async with world since it may change level next tick) 
var world : World_Handler #this should be set and updated by the game. 

#
#TODO: pawn state probably will not be used
#this may not be useful, but here as a way to change state and update
#the state do not need to be known, just when something happen, the signal need to emit
#var pawn_state: Pawn_State :
#	set(value):
#		pawn_state = value
#	get:
#		return pawn_state

#NOTE: hud is not a var, but works?
#maybe because the logic is not being run before this is ready
#may or may need to set it to use a var or use the function
#var i heard is faster than a fuction. just need an on_ready
func get_hud():
	return $HUD
#BUT this class needs a hud var to acess hud
@onready var hud = $HUD


func _ready():
	#this is to test the signal
	#player_meta_changed.connect(player_meta_changed_test)
	pass
	
	if state == null :
		state = Player_State.new() 
		#this also could be where loading state happens if state is created when player 'joins'
	if pawn == null:
		#pawn_state = Pawn_State.Null
		if has_node("Player"):
			pawn = $Player
			#pawn_state = Pawn_State.Init
			#set pawn to $player if it exist
			#good for testing and automatic set up,
			#but a function should be called instead
		else:
			var pawn_ref = load(default_pawn).instantiate()
			add_child(pawn_ref)
			pawn_ref.name = "Player" #todo: make child of world main scene for objects
			pawn = pawn_ref
	#pawn_state = Pawn_State.Alive
	#on_transfer()
	pawn.inventory.slot_update.connect(on_item_gain)
	hud.player_state = state
	#NOTE and TODO: need a func for when pawn change to update this
	hud.player_pawn = pawn
	event_process() #NOTE: this will run untill stopped(need logic) it is a subroutine

func _physics_process(_delta) :
	#Note: need to locate use_input what setting it (most likly world handler) and instead link it here
	if pawn != null:
		pawn.movement_component.sprint_strength = Input.get_action_strength("Sprint")
		var input_dir = Vector2(Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")).normalized()
		pawn.move(input_dir)
	
		###Check if pawn chunk is loaded
		get_hud().loading = not world.is_chunk_loaded(pawn.global_position, true)
	#running this often untill there a way to grab client player
	#and run the loading gui logic for just client 
	
	#on_pawn_update()#should be called often enough to check world state
		
		#probably should do the old way and register pawn as a loader
		#currently updating in the game_handler. old logic with gui loading still being used
		#until game_handler tell player to update it 
		#get_tree().call_group("World_Handler", "load_chunks", pawn.global_position)


func chunk_update(pos,length,is_loaded):
	#print("chunk ready: " + str(is_loaded) + " " + str(pos) + " | size :" + str(length))
	if is_loaded:
		#if loaded and chunk player is in, then trun off loading screen
		#may need a menu flag, but mostly just need to disable most input when loading
		if (pawn.global_position/length).round() == pos : #(pos/length).round():
			#get_tree().call_group("HUD", "loading", false)
			pass
	else:
		#if chunk pawn in is not loaded, enable loading screen
		if (pawn.global_position/length).round() == pos : #(pos/length).round():
			#get_tree().call_group("HUD", "loading", true)
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
				pawn.global_position+(pawn.movement_component.facing_dirction*24),
				0b10000000_00000000_00000000_00000010, #last is 1, first is 32
				[pawn])
			#NOTE: collsion mask may override each other. so if there two interact on one object for tracing
			#then only the first will trigger
			#0b10000000_00000000_00000000_00001101
			#query.exclude = [local_player]
			var result = space_state.intersect_ray(query)
			if "collider" in result:
			#	Game_Utility.get_action(result["collider"],"on_interact").call(
			#			self, pawn, result["collider"], {}
			#			)
			#	return #returning here to have it check tile for debug reason
			#	#ideally the source 'result["collider"]' would need to be coverted
			#	#to be used with tiles perhaps. or the logic can be push to Game_Utility
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
					Game_Utility.get_action(result["collider"],"on_interact").call(
						self, pawn, result["collider"], {}
						)
					return #this is returning to break below actions. debugging temp solution
					#if result["collider"].has_method("on_interact"):
						#TODO: event data pass may be empty unless extra data is needed
						#NOTE: most of the event data and logic will be scraped.
						#the data should be stored at this scope untill the logic finish
						#so the data could be probed if needed
					#	var event_data = {
						#	"type": "interact", 
						#	"instigator":pawn,
						#	"handler":self,#handler is the handler. instigator is the one who started it
						#	"status": 1, #0 is finished or init. -1(or less) is cancled, and 1+ is running 
						#	"run": func(data): return Player_Handler.default_event_action(data)
					#	}
					#	interact.emit(self, pawn, result["collider"], event_data)
					#	if(event_data.has("canceled")):
					#		print("on_interact was canceled")
					#	else:
					#		print("meowing")
					#		result["collider"].on_interact(self, pawn, result["collider"], {})
							#below push the logic to the old event loop
							#event_data = result["collider"].on_interact(self, pawn, result["collider"], {})
							#if event_data != null:
							#	handle_event(event_data)
				#var test = Dialog_Script_Resource.new()
				#test.default_script = "this is a test \n meow mew"
				#print(test.get_dialog_text())
				#var test2 = Catch_Fish.new()
				#test.fail_weight = 10
				#test2.random_table = test
				#test2.interact(self,pawn,null,{})
				#print(test.pick_from_table(true))
			#pawn.inventory.add_item(Item.new_item(Item, 10))
			#print(pawn.inventory.items)
		#elif event.is_action("Cancel") && event.is_action_pressed("Cancel"):
			#pawn.inventory.add_item(Item.new_item(Item, -5))
			#print(pawn.inventory.items)

###Player Event Handler###
#NOTE: this logic use may or may not be used
#It just a repeating function with a state related to
#the player that can be assign from other sources
#region 
var active_events = {}
static func default_event_action(data):
	data["Test"] = "meow the default run function was called"
	if data.has("default_repeats"):
		data["default_repeats"] += 1
	else:
		data["default_repeats"] = 1
	#NEED to make sure the event is canceled if default is used
	data["status"] = 0
	return data
func handle_event(event):
	#TODO remove this or have this check pass events
	#to vaildate them before adding to active_events 
	if event.has("status") and event.has("run"):
		if event["status"] > 0:
			#event vaild enough to added
			#NOTE: may always be conside vaild depending on the run
			var id = null
			var type = "event"
			#events wont stack if they have the same type or type and id
			#id usally the other party invold id. 
			#if an event can stack, then addtional logic is needed
			if event.has("id"):
				#id is a set id to used
				id = event["id"]
			if event.has("type"):
				type = event["type"]
			if id != null:
				active_events[type+":"+id] = event
			else:
				active_events[type] = event
func event_process():
	while true: #not active_events.is_empty(): #need to stay running untill handler ending. 
		for event_id in active_events.keys():
			var event = active_events[event_id]
			if event.has("run"):
				event["run"].call(event) 
				print_debug(event)
				if event.has("status"):
					if event["status"] <= 0:
						active_events.erase(event_id)
				else:
					active_events.erase(event_id)
			else:
				print_debug("reaccuring even have no run callable")
				active_events.erase(event_id)
		await get_tree().create_timer(1.0).timeout
#endregion

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

#may not use this in the long run. may just directly use state and listen
#to the state signal if needed
func set_player_meta(property, value):
	var old_value = state.fetch(property)
	state.store(property,value)
	#var old_value = get_player_meta(property)
	#state.metadata[property] = value
	#player_meta_changed.emit(state, property, old_value)
func get_player_meta(property):
	#DEPRECATED use state functions
	push_warning("deprecated code called")
	return state.fetch(property)
	#if (state.metadata.has(property)):
	#	return state.metadata[property]
	return null
	
func player_meta_changed_test(player_state, property, old_value):
	#DEPRECATED use state functions
	push_warning("deprecated code called")
	print("state: "+ str(player_state))
	print("property: "+ str(property))
	print("old_value: "+ str(old_value))
