class_name World_State extends State

##NONE type refers to default level set up
##LOAD type refers restoring level from save
##EXIT type refers to using exit data to set up the level
enum TRANSFER_TYPE{NONE,LOAD,EXIT}
enum WORLD_TYPE{TOP_DOWN, PLATFORM, OTHER}

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
		
@export var world_type : WORLD_TYPE = WORLD_TYPE.TOP_DOWN #or "platform" #or others. may use an enum
#@export var gravity_enable : bool = false #not needed. world type can disable it or zero gravity direction can also
@export var gravity : float = 98
@export var max_gravity : float = 980
@export var gravity_direction : Vector2 = Vector2(0.0,1.0)

#This may be used more as a ref of the current level
#but player's exit_data may keep the last and current level
#for saving reasons
var level_uid : String = default_level_uid

##This represent the reason for the last transfer
##and is used for other sysyems to deside how to handle the data
##0: new game (use default data)
##1: loaded game (use data from a loaded file)
##2: exit triggered (exit data vaild)(used info in exit data
var transfer_type : TRANSFER_TYPE = TRANSFER_TYPE.NONE

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
func load_level(uid:String, type:TRANSFER_TYPE = TRANSFER_TYPE.NONE)->void:
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
	
func gravity_enable():
	#will return true unless type disable it
	if (world_type == WORLD_TYPE.TOP_DOWN):
		return false
	return true
