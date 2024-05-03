class_name Resource_Handler extends Node

#NOTE: maybe use savable state since this basily a state.
#also maybe the savable state should handle config files save/loading

#will store paths to files so more than one can acess it
@export var client_settings_file: String = "user://client_settings.cfg"
@export var server_settings_file: String = "user://server_settings.cfg"
@onready var auto_save: Timer = %Auto_Save

@export var save_path : String = "user://"
@export var current_save_name : String = "Default"

func get_save_path(create_path:bool=true)->String:
	var path = save_path +"/"+current_save_name
	if !DirAccess.dir_exists_absolute(path) and create_path:
		DirAccess.make_dir_recursive_absolute(path)
	return path

var configs :={}
var configs_to_save:Array[String] = []

#todo: maybe have this store the in a dict
#also config files seem to not exist after a while, but sometime they are fine
#this working fine since the other is catching the ref long term
func get_settings(path:String)->ConfigFile:
	if !configs.has(path):
		configs[path] = ConfigFile.new()
		configs[path].load(path)
	return configs[path]

func save_settings(path:String, queue:bool=true):
	if !configs.has(path):
		print_debug("config is null")
		return
	var config = configs[path]
	if queue:
		if !configs_to_save.has(path):
			configs_to_save.append(path)
			if auto_save != null:
				if auto_save.is_stopped():
					auto_save.start()
	else:
		config.save(path)

func _on_auto_save() -> void:
	if !configs_to_save.is_empty():
		save_settings(configs_to_save.pop_front(),false)
	elif !auto_save.is_stopped():
		auto_save.stop()
	

func _ready() -> void:
	auto_save.timeout.connect(_on_auto_save)

