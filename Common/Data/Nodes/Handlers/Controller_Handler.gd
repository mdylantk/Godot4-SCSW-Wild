##This is the base class for controllers. Player and AI controllers should extend from this
class_name Controller_Handler extends Node

signal save_state_changed(old:State, new:State)

##This is the default brain the controller will use to talk to its owning units
##controllers could use more than one brain, but usally one is all that is needed
##(note: the brain can contain slots for a behavor tree. controller just assignt varibles
##that may not be known by the pawn. imagin a hivemind calling to its minions to come home
##the handler would set the prority to return home and make sure home location is the hive
##the the minions will try to reach it while doing other tasks base on the brains logic and 
##componets. NOTE: the brain do not need to have componets for this as long as it have
##signals for the pawn to listen to. then it be more of a messager system) 
#@export var controller_brain : Base_Brain :
#	set(value):
		#this just a failsafe. Normally brain should not be freed 
		#unless major change in game mode 
#		if controller_brain != value:
#			if controller_brain  != null:
#				controller_brain.removed.emit()
				#could also try to free it
#		controller_brain = value

##NOTE: this is plan to replace controller brain
##(brain and controllers should be seperated. A brain may have a controller assign)
@export var controller : Controller
#NOTE: may not add the remove logic. controllers should not be created dymanicly
#remove may be added if game require the controller to change in the handler
var save_state : Savable_State:
	set(value):
		var old_state = save_state
		save_state = value
		if old_state != save_state:
			save_state_changed.emit(old_state,save_state)
#NOTE: state will be handle diffrently. also this handler may be out of date?
#or need to be check to make sure things are being used, ideally save functions
#can be useful since this may have a state that need to be saved
#NOTE: may not use get state as it was orginally design. indirectly using
#resource with load tends to not work
func get_state()->State:
	return null

##returns a node the controller is controlling. index is used if the controll 
##is controlling more than one pawn.
func get_pawn(index:int=0)->Node:
	return null

##shared functionality that state that a new pawn should be controlled
##AI may stash it in an array while player may replace the current pawn
func handle_pawn(pawn:Node)->void:
	pass
##shared functionality that state that a new pawn should no longer be controlled
##If player only have one pawn, this would remove it and the player lose acess to a pawn
##if handle pawns are stored in an array, then they would be removed
func unhandle_pawn(pawn:Node)->void:
	pass
	
func on_level_changed(level:Base_Level, spawn_index: int = 0):
	pass
	
func _ready() -> void:
	World.level_changed.connect(on_level_changed)
	
#func on_autosave(path : String = ""):
#	print_debug("autosaving")
#	var active_state = get_state()
#	if active_state != null:
#		active_state.save_state()
	
#func on_game_loaded(path : String = ""):
#	print_debug("loaded")
#	var active_state = get_state()
	#NOTE: need to recreate the self handling of the state like in character2d
	#or depend on data handler to store values, but that should be reserver for
	#globals
#	if active_state:
#		active_state.load_state()
	
	
func on_new_game(path:String = ""):
	save_state = Savable_State.new()
	
#TODO: decide if the game handle should absorb these handlers
#and move the bulk of the roles to the state. only reason to keep
#them split is to keep the game handler smaller and the global space
#less clutter. also some things can only be acesses as scene so having a 
#scene base handler (either the game or a dedicated one) is idea
#NOTE: may move most handlers as a child of the game handler to remove from
#global space. Game may need to stay as an autoload so level loading do not reset it

func on_game_loaded(path:String = ""):
	var full_path = path + "controllers/" + name + ".tres"
	if ResourceLoader.exists(full_path):
		save_state = ResourceLoader.load(full_path,"",0)
	if save_state == null:
		on_new_game(full_path)
	print_debug("loaded",save_state,' ',full_path)
		

func on_autosave(path : String = ""):
	var full_path = path + "controllers/"
	if save_state:
		save_state.fetch_save_data()
		if !DirAccess.dir_exists_absolute(full_path):
			DirAccess.make_dir_recursive_absolute(full_path)
		full_path = full_path + name + ".tres"
		ResourceSaver.save(save_state, full_path)
		print_debug("autosaving ", full_path)
