class_name Player_Handler extends Controller_Handler

@export var state : Player_State

#@export_file("*.tscn") var default_pawn = "res://Data/Node/Actors/Player.tscn"
@export var default_pawn : PackedScene = load("uid://bugclr6n3igb4")



var pawn:Character2D #pawn may be move around, so a direct ref will be used to track it
var uid:int = 0 #may or may not be needed if there a built in way to get a user id\

var pawns_interactor:Interactor_Base

#TODO decide to add a input_enable flag to handle disabling player input
#or see if godot have a way to stop sending input here

#catch the movement since the pawn moves every frame. 
var movement_input: Vector2

var paused : bool = false:
	set(value):
		paused = value
		
		if !paused : return
		if pawn == null : return
		if pawn.brain_component == null : return
		pawn.brain_component.set_direction(Vector2())
		

#may need to use a scene of a camera incase the camrea is deleted with pawn before reparented
#or try to listen for changes that may cause it to be deleted
@onready var controller_camera : Camera2D = %Camera2D

func get_state()->Savable_State:
	return state
func get_pawn(index:int=0)->Character2D:
	return pawn

func _ready():
	super()
	#this is to test the signal
	#player_meta_changed.connect(player_meta_changed_test)
func setup():
	if state == null :
		state = Player_State.new()
		#TODO: should also add a player id to it once a system is added to handle it
		#also for single player, player and game should be contain in a save folder so more than
		#one save can be created
		state.file_name = "player_state"
		#this also could be where loading state happens if state is created when player 'joins'
	#state.load_state()
	if pawn == null:
		#pawn = default_pawn.instantiate()
		possess_pawn(default_pawn.instantiate())
		#pawn.add_to_group("player_controlled")
		General_Events.spawn_entity(pawn)
		#pawn.interacted.connect(on_pawn_interaction)
		
		#NOTE: when switching pawns, inventory will be diffrent(or should)
		#so need a way to add id to inventorys if it a presistant object
		#uid may work in some cases, but adding number to end if exist and force
		#to create may be another way, but they would need to be loaded in
		#also could try to save the character fully at the cost of changes breaking 
		#things.
		#var test_inv = state.fetch("inventory", "pawn")
		#print_debug(test_inv)
		#if test_inv != null:
		#	pawn.inventory.inventory = test_inv
	#TODO: need a func to possess and unpossesed pawns so the data
	#is correct.
	#players group is a group that holds all player pawns. used
	#for checking if a character is player own for cases where
	#actions are trigger only for players, but do not need a player_handler to work
	
	#pawn_state = Pawn_State.Alive
	#on_transfer()
	


func possess_pawn(new_pawn: Node):
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
	#an attempt to save the camera from being freed
	if pawn.is_queued_for_deletion():
		controller_camera.reparent(self)

func handle_pawns_connections(target_pawn:Node, remove:bool = false):
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
	var interaction : Interactive_Component = collider as Interactive_Component
	if interaction != null:
		interaction.interact(self,source_pawn,collider,data)

#func _physics_process(_delta) :
#	if pawn != null:
#		pawn.move(movement_input)
		#this will be used unless a generic point can be predicted to use for the
		#pawn to move to

func _unhandled_input(event:InputEvent):
	if paused : return
#func input_update(event:InputEvent):
	#movement for the pawn(return is pawn is null
	if pawn == null : return
	#if state.dirty:
	#	state.save_state()
	if event.is_action("Sprint"):
		pawn.movement_component.sprint_strength = event.get_action_strength("Sprint")
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("Accept"):
		if pawns_interactor != null:
			pawns_interactor.interact(pawn)
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
		if pawn.brain_component != null:
			pawn.brain_component.set_direction(Vector2(
				Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")
			).normalized())
			get_viewport().set_input_as_handled()





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

#TODO: have the level or game create a new pawn base on a template
#either here or in the game mode. the pawn could also be generic and have it appearnce
#change when a new stat is loaded.
#NOTE TODO: use this indead of the group calls with the new system
#but pass a spawn point so the player can decided how to spawn in
#though havining the level handle this would be better
#the issue is dealing with dynamic spawn character allies
#also need to decided on either keeping pawns between levels or recreating them
#this may be base on how much overhead there is in recreating. recreating would allow
#levels more control of the type of pawn used (can easly override it)
func on_level_changed(level:Base_Level, spawn_index: int = 0):
	if level != null and pawn != null:
		pawn.reparent(level)
		pawn.global_position = level.get_spawn_position(spawn_index, self)
	
func reparent_pawn(new_level:Node):
	pawn.reparent(new_level)
	
func relocate_pawn(new_location:Vector2,player_index:int=0):
	if player_index == 0 and pawn != null:
		pawn.position = new_location

##will use a save point (or 0,0 if none)
func relocate_pawn_from_saved_point(level_id:String,player_index:int=0,default:Vector2=Vector2()):
	#print_debug(name.split("Player_Handler")[1])
	if player_index == 0 and pawn != null:
		#TODO: should check if it exist, else use a pass loction
		var new_location = state.fetch(level_id,"positions")
		print_debug(new_location)
		if new_location == null:
			pawn.position = default
		else:
			pawn.position = new_location
	else:
		pass
