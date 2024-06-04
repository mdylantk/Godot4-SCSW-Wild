class_name Player_Handler extends Controller_Handler

@export var state : Player_State

#@export_file("*.tscn") var default_pawn = "res://Data/Node/Actors/Player.tscn"
@export var default_pawn : PackedScene = load("uid://bugclr6n3igb4")



var pawn:Character2D #pawn may be move around, so a direct ref will be used to track it
var uid:int = 0 #may or may not be needed if there a built in way to get a user id\

var pawns_interactor:Interactor_Base

#catch the movement since the pawn moves every frame. 
var movement_input: Vector2

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
	
	if state == null :
		state = Player_State.new()
		#TODO: should also add a player id to it once a system is added to handle it
		#also for single player, player and game should be contain in a save folder so more than
		#one save can be created
		state.file_name = "player_state"
		#this also could be where loading state happens if state is created when player 'joins'
	state.load_state()
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
		var test_inv = state.fetch("inventory", "pawn")
		if test_inv != null:
			print(test_inv)
			pawn.inventory.items = test_inv
	#TODO: need a func to possess and unpossesed pawns so the data
	#is correct.
	#players group is a group that holds all player pawns. used
	#for checking if a character is player own for cases where
	#actions are trigger only for players, but do not need a player_handler to work
	
	#pawn_state = Pawn_State.Alive
	#on_transfer()
	pawn.inventory.slot_update.connect(on_item_gain)


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
	controller_camera.reparent(new_pawn)
	
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


func input_update(event:InputEvent):
	#movement for the pawn(return is pawn is null
	if pawn != null :
		#test
		if state.dirty:
			#print_debug("saving")
			state.save_state()
		#test end
#		movement_input = Vector2(
#			Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")
#			).normalized()
		if event.is_action("Sprint"):
			pawn.movement_component.sprint_strength = event.get_action_strength("Sprint")
			
		if event.is_action_pressed("Accept"):
			if pawns_interactor != null:
				pawns_interactor.interact(pawn)

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
#NOTE: test prove that current system can save resource base items
#just need to test if it works in arrays
#WARNING: works with arrays, but not flagging dirty since the arrays
#contains resources of the same id. so the changes are not noticable
#could force it to flag as dirty or could keep using dictionary as data
#since all the logic is in place. 
#NOTE: could warp the item dictionary with the item, but require the item resource
#path to be known and require looping inventories before saves. better as it a dictionary
#can use static classes to interact with it for reability
#NOTE: TODO: maybe should force the dirty flag. resources support types and
#it helps with readablity and helps with odd(yet quick) fix like loading the resource
#before acessing it. may not be needed here. just need to change the fuctions to work
#with self and provide the data. amount, durability, quality, and a dictionary call meta
#and anything else that is going to be commonly used. meta for the less common modifiers
#Note that the saves will break more often if the item structure changes.
#		if event.is_action("ScrollLeft"):
#			if item1 == null: item1= Item.new()
#			if item2 == null: 
#				#item2 = load("res://Data/Resources/Fish_Item.tres")
#				item2= Item.new()
#			print_debug(item1.is_similar_to(item2))
#			var items : Array[Item]
#			#print(state.fetch("items","test"))
#			if state.fetch("items","test") != null:
#				items = state.fetch("items","test")
#			if items.is_empty():
#				items.append(Item.new())
#			print_debug(items)
#			print(items[0].amount)
#			items[0].amount = items[0].amount + 1
#			state.store("items",items,"test",true)
#			print(state.dirty)

#TEST:
#var item1:Item
#var item2:Item

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
	print_debug("new: "+ str(inventory.items[slot]))
	state.store("inventory", inventory.items, "pawn")
	print_debug(state.data)
	pass
	
func on_level_changed(level:Base_Level, spawn_index: int = 0):
	if level != null and pawn != null:
		pawn.reparent(level)
		pawn.global_position = level.get_spawn_position(spawn_index, self)
