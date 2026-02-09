class_name Game_State extends State
#These are to signal change in game state
#the goal is to use this instead of group calls
#and allow the game to directly trigger it
signal save_event(path : String)
signal load_event(path : String)
signal new_game_event()

@export var default_path : String = "user://"

@export var default_save_name : String = 'default'
##if true, it will override default_random_seed
@export var randomize_seed : bool = true
@export var default_random_seed : int = 0
@export var default_game_time : int = 0

var random_seed : int = default_random_seed
var new_game : bool = true
var save_name : String = default_save_name

#this is expose here so that debug can check the value
#might move it here if needed and it may
var pause_state : int

#todo: decide if miliseconds should be kept
#though having the game 10 times faster than reallife
#is not that bad
#game_time is the general passage of time. each world or level
#could have their own time that overrides or modify this
#it also acts as the default time when debugging
var game_time : int = default_game_time
#time in day is just a helper to get a something to 
#divide with to get a 0-1.0 value between curent to next midnight
#may have something else to help with that in the world state or something
#not a const since I was thinking about exporting it, but not sure since
#it may change still.
var time_in_day : float = 3600.0

static func get_default_instance()-> State:
	return load('uid://cnbeqfpaumxj3')

func get_save_path()->String:
	return default_path + '/' + save_name + '/'


func _reset_state() -> void:
	if randomize_seed:
		randomize()
		random_seed = randi()
	else:
		random_seed = default_random_seed
	game_time = default_game_time
	#NOTE: this should change by ui, but it may be better
	#to use the default save name first and then modify
	save_name = default_save_name
	
	
func get_save_data()->Dictionary[String,Variant]:
	saving.emit()
	var save_data : Dictionary[String,Variant]
	save_data.set('_random_seed',random_seed)
	#save_data.set('new_game',new_game) #might not need to save this
	save_data.set('_game_time',game_time)
	#save_data.set('data',get_metadata())
	save_data.set('_save_name',save_name)
	return save_data
	

#and load will load the pass data (if changed) and then notify
#all that it is ready(aka loaded)
func load_data(new_data:Dictionary[String,Variant]={})->void:
	random_seed = new_data.get('_random_seed', default_random_seed)
	#new_game = new_data.get('new_game', new_game)
	game_time = new_data.get('_game_time', default_game_time)
	#set_metadata(new_data.get('data', get_metadata()))
	#data = new_data.get('data', data)
	save_name = new_data.get('_save_name', default_save_name)
	loaded.emit()
	
