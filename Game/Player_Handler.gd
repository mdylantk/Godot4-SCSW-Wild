class_name Player_Handler extends Controller_Handler

@export var state : Player_State = Player_State.get_default_instance()
@export var game_state : Game_State = Game_State.get_default_instance()

#@export_file("*.tscn") var default_pawn = "res://Data/Node/Actors/Player.tscn"
#think pawn will be handled by level and their connection base
#on their group ans assigned controller
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

#var pawn:Character2D #pawn may be move around, so a direct ref will be used to track it
var uid:int = 0 #may or may not be needed if there a built in way to get a user id\

#var pawns_interactor:Shaped_Interactor

#TODO decide to add a input_enable flag to handle disabling player input
#or see if godot have a way to stop sending input here

#catch the movement since the pawn moves every frame. 
#var movement_input: Vector2

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

#func get_state()->State:
#	print_debug("NOTE: this is not going to be supported")
	#return save_state
#	return state
	
#func get_pawn(index:int=0)->Character2D:
#	return pawn
	
func on_new_game(path:String = "")->void:
	state.reset_state()
	
#NOTE: may not depend on controller handler
#since handler may act diffrently and are more one of a kind
#and some logic flow are harder to break up and have things not easy
#to break depencies
func on_game_loaded(path:String = ""):
	var full_path = path + "controllers/" + name + ".tres"
	var loaded_save : Savable_State
	if ResourceLoader.exists(full_path):
		loaded_save = ResourceLoader.load(full_path,"",0)
	print_debug("loaded",loaded_save,' ',full_path)
	if (loaded_save):
		state.load_data(loaded_save.data)
	print_debug("player state", state)
		
func on_autosave(path : String = ""):
	var new_save_state : Savable_State = Savable_State.new(state.get_save_data())
	var full_path = path + "controllers/"
	if !DirAccess.dir_exists_absolute(full_path):
		DirAccess.make_dir_recursive_absolute(full_path)
	full_path = full_path + name + ".tres"
	ResourceSaver.save(new_save_state, full_path)
	print_debug("autosaving ", full_path)
	

func _ready():
	print_debug("player state", state)
	game_state.save_event.connect(on_autosave)
	game_state.load_event.connect(on_game_loaded)



func _unhandled_input(event:InputEvent):
	if paused : return
	
	if event.is_action("Sprint"):
		if controller != null:
			controller.trigger_action("Sprint",event.get_action_strength("Sprint"))
			get_viewport().set_input_as_handled()

	if event.is_action_pressed("Accept"):
		if controller != null:
			controller.trigger_action("Interact",1)
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
