#fish log is a helper for setting and reading the fish log collection
#it might handle its own save state if needed.
#not sure if this can be a static class since it depends on
#player state instance. (it can load is as needed, but I rather cache the ref) 
#TODO: test this and make log ui as well as make sure collected fishes are logged
#(NOTE: May need to extend the add item action or have an action that manages both
#adding the item and sending it to the log. NOTE: cought dose not mean gained
#so it do not need to be handled with the add item if the fishing minigame handles
#it. it just need a way to know if it a loggable catch
#also could log non_fish catches, but may need to not use int as a key
#and use a string. also the uid is to allow loading the item for the gui
#so the size and weight can be caculated. could instead assign it as a property
#instead of an id
class_name Fish_Log extends RefCounted

enum COLLECTION_TYPE {CAUGHT,DELIVERED}

#@export var player_state : Player_State = load('uid://c67c2fehtuhni')

var _data : Dictionary #: 
	#get:
#		return player_state.get_collection('fish_log') as Dictionary[String,Variant]

func get_fish_id(fish:Item_Type)->int:
	return ResourceLoader.get_resource_uid(fish.resource_path)

func get_fish_from_id(fish_id)->Item_Type:
	if ResourceUID.has_id(fish_id):
		return load(ResourceUID.get_id_path(fish_id))
	return

func get_log_of_fish(fish_id:int)->Dictionary:
	if fish_id == -1:
		push_error('item dose not have an id.')
		return {}
	if !_data.has(fish_id):
		_data.set(fish_id,{})
	return _data.get(fish_id)

func add_fish_to_log(
		fish_id:int,
		amount:int=1,
		size:float=0.0,
		collection_type:COLLECTION_TYPE = COLLECTION_TYPE.CAUGHT
	)->void:
	var current_log : Dictionary = get_log_of_fish(fish_id)
	var collection_type_id : String = COLLECTION_TYPE.keys()[collection_type]
	var old_amount : int = current_log.get(collection_type_id,0)
	var min_size : float = current_log.get(collection_type_id+'min_size',0.0)
	var max_size : float = current_log.get(collection_type_id+'max_size',0.0)
	current_log.set(collection_type_id, old_amount + amount)
	if size > 0.0:
		if size > max_size:
			current_log.set(collection_type_id+'max_size', size)
		if size < min_size || min_size <= 0.0:
			current_log.set(collection_type_id+'min_size',size)
	pass
#func _run(data:Action_State) -> bool:
#	var fish_log:Dictionary[String,Variant] = player_state.get_collection('fish_log')
#	if !fish_log.has(fish_id):
#		fish_log.set(fish_id,{})
#	var fish_collection:Dictionary[String,Variant] = fish_log.get(fish_id)
#	var property_id : String
#	if collection_type & 1 << 0:
#		property_id = 'caught'
#	elif collection_type & 1 << 1:
#		property_id = 'delivered'
#	else:
#		return false
#	if modify_type == 0:
#		var old_amount:int = fish_collection.get(property_id,0)
#		var min_size :float = fish_collection.get(property_id+'min_size',0.0)
#		var max_size :float = fish_collection.get(property_id+'max_size',0.0)
#		fish_collection.set(property_id,old_amount + amount)
#	elif modify_type == 1:
#		fish_collection.set(property_id,amount) 
#		
#	return true
