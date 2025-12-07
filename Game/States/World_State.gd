class_name World_State extends State

signal load_level(uid:String, spawn_index : int)
signal level_loaded(new_level : Base_Level, spawn_index : int)
signal level_busy()
signal level_ready()
#not sure if changed is needed and if loaded the same one
#signal level_changed(level:Base_Level, spawn_index: int)

@export var default_level_uid : String = "uid://cldlaymbe77mn" :
	set(value):
		default_level_uid = value
		level_uid = value

var level_uid : String = default_level_uid

var is_level_loading : bool = false :
	set(value):
		if value != is_level_loading:
			is_level_loading = value
			if is_level_loading:
				level_busy.emit()
			else:
				level_ready.emit()
				
				
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
