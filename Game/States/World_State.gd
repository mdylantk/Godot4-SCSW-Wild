class_name World_State extends State

signal level_transfer(uid:String)
signal level_loaded(new_level : Base_Level)
signal level_busy()
signal level_ready()
#not sure if changed is needed and if loaded the same one
#signal level_changed(level:Base_Level, spawn_index: int)

@export var default_level_uid : String = "uid://cldlaymbe77mn" :
	set(value):
		default_level_uid = value
		level_uid = value

#This may be used more as a ref of the current level
#but player's exit_data may keep the last and current level
#for saving reasons
var level_uid : String = default_level_uid

##This represent the reason for the last transfer
##and is used for other sysyems to deside how to handle the data
##0: new game (use default data)
##1: loaded game (use data from a loaded file)
##2: exit triggered (exit data vaild)(used info in exit data
var transfer_type : int = 0

#TODO:decide if it should be is_level_ready(inverted bool) or not
#also the signals might not be reliable
#may be better to handle as an int? but that would require the level
#to set it if not used unless the game have a period where if the value
#is not changed, it will mark it as ready else it would leave it to the level
#to change it.
var is_level_loading : bool = false :
	set(value):
		if value != is_level_loading:
			is_level_loading = value
			if is_level_loading:
				level_busy.emit()
			else:
				level_ready.emit()
				

static func get_default_instance()-> State:
	return load('uid://b047ftosxvj7p')

#NOTE: need to handle invaild cases
func load_level(uid:String, type:int = 0)->void:
	is_level_loading = true
	transfer_type = type
	level_transfer.emit(uid)
	

func _reset_state() -> void:
	level_uid = default_level_uid

func get_save_data()->Dictionary[String,Variant]:
	var save_data : Dictionary[String,Variant]
	saving.emit()
	save_data.set('level_uid',level_uid)
	save_data.set('data',get_metadata())
	return save_data

func load_data(new_data:Dictionary[String,Variant]={})->void:
	level_uid = new_data.get('level_uid',level_uid)
	set_metadata(new_data.get('data', get_metadata()))
	loaded.emit()
