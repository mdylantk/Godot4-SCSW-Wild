class_name Game_State extends Savable_State
#These are to signal change in game state
#the goal is to use this instead of group calls
#and allow the game to directly trigger it
signal save_event(path : String)
signal load_event(path : String)
signal new_game_event()


@export var default_path : String = "user://"

var random_seed : int = 0
var new_game : bool = true
var save_name : String = 'default'

#this is expose here so that debug can check the value
#might move it here if needed and it may
var pause_state : int


func get_save_path()->String:
	return default_path + '/' + save_name + '/'


#func _reset_state() -> void:
	#pass
	
	
func get_save_data()->Dictionary[String,Variant]:
	saving.emit()
	var save_data : Dictionary[String,Variant]
	save_data.set('random_seed',random_seed)
	save_data.set('new_game',new_game)
	save_data.set('data',get_metadata())
	return save_data
	

#and load will load the pass data (if changed) and then notify
#all that it is ready(aka loaded)
func load_data(new_data:Dictionary[String,Variant]={})->void:
	random_seed = new_data.get('random_seed', random_seed)
	new_game = new_data.get('new_game', new_game)
	set_metadata(new_data.get('data', get_metadata()))
	#data = new_data.get('data', data)
	loaded.emit()
