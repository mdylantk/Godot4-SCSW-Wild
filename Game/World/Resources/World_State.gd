class_name World_State extends Base_Events

signal load_level(uid:String, spawn_index : int)
signal level_loaded(new_level : Base_Level, spawn_index : int)
signal level_busy()
signal level_ready()
#not sure if changed is needed and if loaded the same one
#signal level_changed(level:Base_Level, spawn_index: int)

var is_level_loading : bool = false :
	set(value):
		if value != is_level_loading:
			is_level_loading = value
			if is_level_loading:
				level_busy.emit()
			else:
				level_ready.emit()
