class_name Player_Handler extends Controller_Handler

@export var state : Player_State = load('uid://c67c2fehtuhni')

#@export_file("*.tscn") var default_pawn = "res://Data/Node/Actors/Player.tscn"
@export var default_pawn : PackedScene = load("uid://bugclr6n3igb4")

#TODO: try to handle input with the brain. can send input or handle t directly inside it
#NOTE: pawn loading should be done by level with the player(or world->game) handling
#spawning one if non exist in the level (not nessary)
#so level goal is to be able to get points for all players and provide a character for them
#(if they are able to have control). and then make sure to assign them the player controller
#level should be sync over the network so the assign would happen on client side after
#server calls it. just need to make sure client can find the pawn they own(could do that serval ways
#if ref can not be pass over network...like tagging/groups or the actual picking logic)
#@export var controller_brain : Base_Brain = Player_Controlled_Brain.new():
#	set(value):
#		#this just a failsafe. Normally brain should not be freed 
#		#unless major change in game mode 
#		if controller_brain != value:
#			if controller_brain  != null:
#				controller_brain.removed.emit()
#				#could also try to free it
#		controller_brain = value

var pawn:Character2D #pawn may be move around, so a direct ref will be used to track it
var uid:int = 0 #may or may not be needed if there a built in way to get a user id\

var pawns_interactor:Interactor_Base

#TODO decide to add a input_enable flag to handle disabling player input
#or see if godot have a way to stop sending input here

#catch the movement since the pawn moves every frame. 
var movement_input: Vector2

var paused : bool = false:
	#this stop input when this paused is true
	#basicly when game pause, player pause too so this was a workaround
	#TODO: see if there a way to listen to the game pausing
	#else make sure something like this get enforce
	set(value):
		paused = value
		
		if !paused : return
		#if pawn == null : return
		#if controller_brain == null : return
		#controller_brain.set_direction(Vector2())
		if controller != null :
			controller.set_direction(Vector2())
		

#may need to use a scene of a camera incase the camrea is deleted with pawn before reparented
#or try to listen for changes that may cause it to be deleted
@onready var controller_camera : Camera2D = %Camera2D

func get_state()->Savable_State:
	print_debug("NOTE: this is not going to be supported")
	#return save_state
	return state
func get_pawn(index:int=0)->Character2D:
	return pawn
	
func on_new_game(path:String = ""):
	#TODO: FIGURE out how to save the state without changing the path
	#also so that all that use that path will get the correct resource
	#and not the old one
	#may or may not need to manually update the state.
	state.exit_data = Exit_Data.new()
	state.scores = {}
	state.positions = {}
	state.position = Vector2.ZERO
	state.facing = Vector2.ZERO
	
func on_game_loaded(path:String = ""):
	super(path)
	if (save_state):
		state.exit_data = save_state.get_value('exit_data',state.exit_data)
		state.scores = save_state.get_value('scores',state.scores)
		state.positions = save_state.get_value('positions',state.positions)
		state.position = save_state.get_value('position', state.position)
		state.facing = save_state.get_value('facing', state.facing)
		state.on_load()
	print_debug("player state", state)
		
func on_autosave(path : String = ""):
	if save_state:
		save_state.set_value('exit_data',state.exit_data)
		save_state.set_value('scores',state.scores)
		save_state.set_value('positions',state.positions)
		save_state.set_value('position',state.position)
		save_state.set_value('facing',state.facing)
	super(path)
	

func _ready():
	print_debug("player state", state)
	pass
	#on_game_loaded(Data.default_path)
	#super()
	#this is to test the signal
	#player_meta_changed.connect(player_meta_changed_test)
	#if state == null :
	#	state = Player_State.new()
		#TODO: should also add a player id to it once a system is added to handle it
		#also for single player, player and game should be contain in a save folder so more than
		#one save can be created
	#	state.file_name = "player_state"
		#this also could be where loading state happens if state is created when player 'joins'
	#state.load_state()

	


func possess_pawn(new_pawn: Node):
	print_debug("this should not be used anymore")
	return
	if pawn != null:
		pawn.remove_from_group("player_controlled")
		handle_pawns_connections(pawn,true)
		#pawn.interacted.disconnect(on_pawn_interaction)
		#pawn.tree_exited.disconnect(on_pawn_exited_tree) 
	pawn = new_pawn
	new_pawn.add_to_group("player_controlled")
	handle_pawns_connections(new_pawn)
	#new_pawn.interacted.connect(on_pawn_interaction)
	#new_pawn.tree_exited.connect(on_pawn_exited_tree) 
	#NOTE: decide on how the camera works. can get a ref from the
	#viewport so the camera owner can change without keeping track of
	#the camera
	controller_camera.reparent(new_pawn)
	
	#NOTE  below should be handle diffrently
	#just here because debugging
	await get_tree().process_frame
	pawn.inventory.slot_update.connect(on_item_gain)
	#var test_inv = state.fetch("inventory", "pawn")
	#print_debug(test_inv)
	#print_debug(state.fetch("pawn","inventory"))
	#if test_inv != null:
	#	pawn.inventory.inventory = test_inv
	
func on_pawn_exited_tree():
	print_debug("this should not be used anymore")
	#an attempt to save the camera from being freed
	if pawn.is_queued_for_deletion():
		controller_camera.reparent(self)

func handle_pawns_connections(target_pawn:Node, remove:bool = false):
	print_debug("this should be change. should not directly handle pawns anymore")
	var interactor:Interactor_Base = Interactor_Base.find_vaild_child(pawn)
	if remove:
		if interactor != null:
			interactor.interaction.disconnect(on_pawn_interaction)
		target_pawn.tree_exited.disconnect(on_pawn_exited_tree) 
		pawns_interactor = null
	else:
		if interactor != null:
			interactor.interaction.connect(on_pawn_interaction)
		target_pawn.tree_exited.connect(on_pawn_exited_tree)
		pawns_interactor = interactor

#NOTE this should be the new system. allow pawn to controll how the data is fetched
func on_pawn_interaction(source_pawn:Node, collider:Node, data:={}):
	print_debug("this should be change. should not directly handle pawns anymore")
	var interaction : Interactive_Component = collider as Interactive_Component
	if interaction != null:
		interaction.interact(self,source_pawn,collider,data)


func _unhandled_input(event:InputEvent):
	if paused : return
	
	if event.is_action("Sprint"):
		if controller != null:
			controller.trigger_action("Sprint",event.get_action_strength("Sprint"))
			get_viewport().set_input_as_handled()
		#
		#if controller_brain != null:
		#	controller_brain.action_triggered.emit("Sprint",event.get_action_strength("Sprint"))
		#pawn.movement_component.sprint_strength = event.get_action_strength("Sprint")
			get_viewport().set_input_as_handled()
	if event.is_action_pressed("Accept"):
		if controller != null:
			controller.trigger_action("Interact",1)
			get_viewport().set_input_as_handled()
		#
		#if controller_brain != null:
		#	controller_brain.action_triggered.emit("Interact",1)
		#if pawns_interactor != null:
			#pawns_interactor.interact(pawn)
			get_viewport().set_input_as_handled()

		#	if result["collider"] is TileMap :
				#below test for tilemap data. keeping for now so it be easier to
				#set up a tile base interaction system like search/forage/look/chop
				#print(result["rid"])
				#print(result["collider"].get_coords_for_body_rid(result["rid"]))
				#print(result["collider"].get_layer_for_body_rid(result["rid"]))
				#print(result["collider"].get_cell_tile_data(
				#	result["collider"].get_layer_for_body_rid(result["rid"]),
				#	result["collider"].get_coords_for_body_rid(result["rid"])
				#))
	if event.is_action_pressed("ScrollRight"):
		#InventoryHandler.add_item(self, pawn,load("uid://nrh8trhov6yk"),100)
		pass
	if event.is_action_pressed("ScrollLeft"):
		#InventoryHandler.add_item(self, pawn,load("uid://nrh8trhov6yk"),-10)
		pass
		
	if (event.is_action("Left") or event.is_action("Right") or
		event.is_action("Forward") or event.is_action("Back")
	):
		if controller != null:
			controller.set_direction(Vector2(
				Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")
			).normalized())
			get_viewport().set_input_as_handled()
		#if controller_brain != null:
		#	controller_brain.set_direction(Vector2(
		#		Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")
		#	).normalized())
		#	get_viewport().set_input_as_handled()





#Region Listerners
func on_item_gain(inventory, slot, old_item):
	#could leave this and just properly connect/disconnect on pawn change
	#the could check the new slot data
	#and if diffrent, run some logic like check if have fish name and of what
	#issue if the fish name is not added to item, the the fish logic would need to 
	#interact with the handler(like it kind of doing now) to do the check
	#NOTE: Big issue is that score is update when unable to store fish
	#but a check with the return value should fix that
	#print("inv: "+ str(inventory))
	#print("slot: "+ str(slot))
	#print("old: "+ str(old_item))
	#state.store("inventory", inventory.items, "pawn")
	#state.store("inventory", inventory.inventory, "pawn")
	#print_debug(state.data)
	pass
