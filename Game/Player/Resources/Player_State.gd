class_name Player_State extends Savable_State

signal score_changed(id:String, new_value:int)


@export var scores : Dictionary = {}

#sets of bitflag ints instead of using
#an array of bools. reserver for when data gets compress
#otherwise data will be used
@export var flags : Array[int] = [] 

#quick way to store info by keys, but should not be used often
@export var data : Dictionary = {}

@export var positions : Dictionary = {}


var pawn #NOTE: this should be the pawn class or a savable data struct for rebuilding the pawn
var world_position : Vector2 #this should be set when traveling or saving. global_position should be used
#for the actual position

#NOTE: instance may not be used. exit_data should have the basic data for loading
#the last level before exiting
var instance = null #the instance the player is in. mostly for loading reasons. 
#may use position instead
var instance_position : Vector2 #similar to world position, but used when loading into an instance
#so set when saving or before loading into an instance from world. (but instance may override it coded that way)

#Exit data is used for loading last zone
@export var exit_data : Exit_Data = Exit_Data.new()
#these are the character last state to be saved
#so they load in like how they load out
@export var position : Vector2
@export var facing : Vector2


#TODO: it is unlikly there be more than one location to store of the player state
#and if there more than one "world" each can have a dedicted varible or the others
#can be added as a meta
#var world_location : Vector2

func set_score(id:String, new_score: int)->void:
	var old_score = 0
	if id in scores:
		old_score = scores[id]
	scores[id] = new_score
	#if old_score != new_score:
	score_changed.emit(id,new_score)
	value_change.emit(id+"_score",new_score,old_score)
	print_debug("meow! set score of ", self, old_score, '->', new_score,' ', id)
	
func get_score(id:String)->int:
	if id in scores:
		return scores[id]
	return 0


func _reset_state() -> void:
	_data.clear()
	exit_data = Exit_Data.new()
	scores = {}
	positions = {}
	position = Vector2.ZERO
	facing = Vector2.ZERO
	flags = []
	
func get_save_data()->Dictionary[String,Variant]:
	saving.emit()
	var save_data : Dictionary[String,Variant]
	save_data.set('exit_data',exit_data)
	save_data.set('scores',scores)
	save_data.set('positions',positions)
	save_data.set('position',position)
	save_data.set('facing',facing)
	save_data.set('flags',flags)
	save_data.set('data',_data)
	return save_data
	

#and load will load the pass data (if changed) and then notify
#all that it is ready(aka loaded)
func load_data(data:Dictionary[String,Variant]={'data':_data})->void:
	exit_data = data.get('exit_data',exit_data)
	scores = data.get('scores',scores)
	positions = data.get('positions',positions)
	position = data.get('position', position)
	facing = data.get('facing', facing)
	flags = data.get('flags', flags)
	_data = data.get('data', _data)
	loaded.emit()
