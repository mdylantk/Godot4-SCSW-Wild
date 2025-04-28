##This handles saving and loading as well as manage persistant state that
##do not have a owning persistant handler
##this meant to replace resource handler since it goal is similar but with an easier name
class_name Data_Handler extends Node

#TODO: add signals to listen to to monitor changes to save state
#as well as add functions to modify the save state so that these will trigger
#the savable state can still be used, but this can be used to make sure the
#states is catched when assign or loaded so the signals can be set up

#TODO: maybe expose some of the config setters and getters here? add a type string
#and if game, player/client, keep in a static spot in memory, else create it for that call
#this would allow swaping the save/load system since everything will be calling from
#this. NOTE: could create three signals and functions for notifing changes,though having
#the state handle it be better. this is for saving and loading. each object can maintain
#its own state.

##will emit when certain save state changes accure. This is not enforced, so not\
##all changes will trigger this.
signal save_state_change(section:String, key:String, value:Variant)
signal save_state_ready()

##this is the key used for the default encryption. The main point of this key
##is to make the save file not easy to read instead. 
@export var default_key : String = "lock"

##this is the default path where save files will be stored
##Note: mostly client and server data would be saved here
##save games should be stored in subdirectories in this path
@export var default_path : String = "user://"

##This is the default name for the save dir. For games that allow
##more than one save, this will be changed on new or save game ui events
@export var save_name : String = "Default"
#config files will be handle directly and will follow "type".cfg or
#"type"_config.cfg. like client.cfg and game.cfg
#@export var client_config: String = "client_config"

##the default object for saving data realted to the current game save
var save_state : ConfigFile
##The object for storing settings
var client_state : ConfigFile

##The main use of this is to make sure there is a dir. This will create
##the dir pase on the path which will allow new saves to be created without an error
func secure_path(path:String)->Error:
	if !DirAccess.dir_exists_absolute(path):
		return DirAccess.make_dir_recursive_absolute(path)
	return OK
	
##This will try to save the provide object to disk
func save_data(
	state:Object,file_name:String="Save",path:String=default_path,encrypted:bool=false,key:String=default_key
	)->Error:
		var full_path = path+"/"+file_name
		secure_path(path)
		if (state as ConfigFile) or (state as Save_File):
			if encrypted:
				return state.save_encrypted_pass(full_path+".save",key)
			else:
				return state.save(full_path+".cfg")
		elif state as Resource:
			if encrypted:
				return ResourceSaver.save(state, full_path+".res")
			else:
				return ResourceSaver.save(state, full_path+".tres")
		else:
			print_debug("State is not a vaild type")
		return 1
		
##This mostly a helper function since resource load diffrent from other
##objects. Save works, but load have to be handle diffrently
func load_resource(
	file_name:String="Saved",path:String=default_path,encrypted:bool=false
	) -> Resource:
		var full_path = path+"/"+file_name
		if encrypted:
			if ResourceLoader.exists(full_path+".res"):
				return ResourceLoader.load(full_path+".res","",0)
		else:
			if ResourceLoader.exists(full_path+".tres"):
				return ResourceLoader.load(full_path+".tres","",0)
		return null
		
##This will try to load a file from disk if the provide object have a way to be loaded
func load_data(
	state
	:Object,file_name:String="Save",path:String=default_path,encrypted:bool=false,key:String=default_key
	)->bool:
	var full_path = path+"/"+file_name
	if (state as ConfigFile) or (state as Save_File):
		if encrypted:
			if FileAccess.file_exists(full_path+".save"):
				state.load_encrypted_pass(full_path+".save",key)
				return true
		else:
			if FileAccess.file_exists(full_path+".cfg"):
				state.load(full_path+".cfg")
				return true
	else:
		print_debug("State is not a vaild type")
	return false


##Save the client settings so autosave would not be needed for settings
func save_settings():
	save_data(client_state,"settings",default_path,false)
	
##Will set up the save_state for a new game or load a save state.
func init_save(save_id:String=save_name,load_save:bool=false):
	save_name = save_id
	if load_save:
		load_data(save_state,"Data",default_path+"/"+save_name,false)
		game_loaded()
	else:
		save_state = ConfigFile.new()
		game_new()
	save_state_ready.emit()

##allow the save_state_change to be called on setting a value
func add_to_save_state(section:String, key:String, value:Variant)->void:
	print_debug("Meow:", section, "key:", key, " value:",value)
	save_state.set_value(section,key,value)
	save_state_change.emit(section,key,value)

var test:Resource = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	save_state = ConfigFile.new()
	client_state = ConfigFile.new()
	load_data(client_state,"settings",default_path,false)
	print_debug("ready")
	#NOTE: can not seem to pass a null resource and set
	#it in the function. I am guessing it treat the ref as a copy
	#so the standalone version works since it returns something to be assign
	#to the class varible
	#load_data(test,"test",default_path,false)
	test = load_resource("test",default_path,false)
	if test:
		print_debug("load data")
	#if load_data(test,"test",default_path,false):
	#	print_debug("loaded data")
	else:
		test = Item.new()
		print_debug("new data")
		test.set_meta("message", "meow")
		test.set_meta("random", randf()*100)
		test.amount = randi_range(1,100)

#TODO: decided on a better group name or spit the group?

##Will notify all existing Savable group members that a new
##game is started
func game_new(path:String = default_path) -> void:
	print_debug("new")
	get_tree().call_group("Savable", "on_new_game",path)

##Will notify all existing Savable group members that a game
##is loaded
func game_loaded(path:String = default_path) -> void:
	print_debug("load")
	get_tree().call_group("Savable", "on_game_loaded",path)

func _on_autosave_timer_timeout() -> void:
	print_debug("(autosave) saving")
	#this allow nodes to prepare there savable data for saving
	#before the state gets saved
	get_tree().call_group("Savable", "on_autosave",default_path)
	save_data(save_state,"Data",default_path+"/"+save_name,false)
	if test:
		save_data(test,"test",default_path,false)
