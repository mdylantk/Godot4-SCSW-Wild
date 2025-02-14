##This handles saving and loading as well as manage persistant state that
##do not have a owning persistant handler
##this meant to replace resource handler since it goal is similar but with an easier name
class_name Data_Handler extends Node

#TODO: add signals to listen to to monitor changes to save state
#as well as add functions to modify the save state so that these will trigger
#the savable state can still be used, but this can be used to make sure the
#states is catched when assign or loaded so the signals can be set up
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
	
func save_data(
	state:ConfigFile,file_name:String="Save",path:String=default_path,encrypted:bool=true,key:String=default_key
	)->Error:
		var full_path = path+"/"+file_name
		secure_path(path)
		if encrypted:
			return state.save_encrypted_pass(full_path+".save",key)
		else:
			return state.save(full_path+".cfg")
			

func load_data(
	state:ConfigFile,file_name:String="Save",path:String=default_path,encrypted:bool=true,key:String=default_key
	)->bool:
	var full_path = path+"/"+file_name
	if encrypted:
		if FileAccess.file_exists(full_path+".save"):
			state.load_encrypted_pass(full_path+".save",key)
			return true
	else:
		if FileAccess.file_exists(full_path+".cfg"):
			state.load(full_path+".cfg")
			return true
	return false

##Save the client settings so autosave would not be needed for settings
func save_settings():
	save_data(client_state,"settings",default_path,false)
	
##should be called when game is ready. It will trigger the save_state_ready
##signal(as well as load the state if flagged) so that other systems can start
##using it. Could allow them to use it on ready, but any changes before the load
##would be erase. They should not set anything, but the signal is to make sure it
##dose not happen.
func init_save(save_id:String=save_name,load_save:bool=false):
	save_name = save_id
	if load_save:
		load_data(save_state,"Data",default_path+"/"+save_name,false)
		game_loaded()
	else:
		#save state should be reset if a game is already started and a new
		#game is requested. 
		save_state = ConfigFile.new()
	save_state_ready.emit()

##allow the save_state_change to be called on setting a value
func add_to_save_state(section:String, key:String, value:Variant)->void:
	print_debug("Meow:", section, "key:", key, " value:",value)
	save_state.set_value(section,key,value)
	save_state_change.emit(section,key,value)
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	save_state = ConfigFile.new()
	client_state = ConfigFile.new()
	
	#config can load on ready
	load_data(client_state,"settings",default_path,false)
	
	#saves should only load on ready for debugging
	#and should be loaded only when new or load game task are performed
	
	
	print_debug("ready")

#TODO: decided on a better group name or spit the group?

func game_loaded() -> void:
	get_tree().call_group("Savable", "on_game_loaded")

func _on_autosave_timer_timeout() -> void:
	print_debug("(autosave) saving")
	get_tree().call_group("Savable", "on_autosave")
	save_data(save_state,"Data",default_path+"/"+save_name,false)
	#save_data(client_state,"settings",default_path,false)
	pass # Replace with function body.
