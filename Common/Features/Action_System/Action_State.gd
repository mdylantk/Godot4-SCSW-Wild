##This is the base object pass by the action run function that contains any nessary
##info for the action event. Extra meta data can be handle by children of this 
##or by using the metadata. The approch depends on what the system design to use
class_name Action_State extends RefCounted
#NOTE:this is a safe notify incase the action state changes
#dedicated signals(of extended classes) can still work, but can break on chain action events.
#TODO: make sure to try to call set_data so this is called
signal data_changed(key:String, value:Variant)

#TODO: the owner and target might need to be stored in
#the _data, but the issue is the data probably should not
#store ref of object (only dict and array)
#if action state needs to be saved to disk, then
#these varibles should be converted to something that can
#be relinked on load. NOTE: this state may not need to be saved
#to disk and if such cases are needed, the node handling that state
#could try to convert the data to something it can load.
#NOTE: action state should act as an interface to data,
#but could hold its own data as long as the current system supports
#passing as a action state. _data acts more as a raw way to acess data
#that wont be loss if action state changes (such as a new action using
#an old action's state).

##the one that calls the actions. most likly character2d
var owner : Node

##the one the action effects. most likly interaction component or
##null. maybe a character2d or some other node in odd cases
var target : Node


#NOTE: the action state might not be used for extended action
#other systems would keep track of the action.
#this is here incase it is still being used
var _action : Base_Action
#will use a dictionary instead of data
#and handle the action state more of a container and
#interface with the data (all properties related to the data
#would be stored in the data and the properties in the class
#will fetch and store to the data while mantaining types and formats)
var _data :Dictionary[String,Variant]

##return the raw data dictionary
func get_data(key:String, default:Variant)->Variant:
	return _data.get(key, default)

##this will emit data_changed if the data is changed. cull_null
##is used to remove null entries from the data.
##NOTE: Data can be changed without it being emitted
##at cases where a new action claimes an old action state.
func set_data(key:String, value:Variant, cull_null:bool = false)-> void:
	var old_value = _data.get(key)
	if cull_null and value == null:
		_data.erase(key)
	else:
		_data.set(key,value)
	if old_value != value:
		data_changed.emit(key,value)

func get_action() -> Base_Action:
	return _action

func _init(new_owner:Node, new_target:Node = null,data:Dictionary[String,Variant]={}) -> void:
	owner = new_owner
	target = new_target
	#NOTE: decided if the meta pass should be used or duplicated. the caller
	#could pass a ref it tracks or duplicate it not the case, but may be misleading
	#where it could use the action state instead
	_data = data
	#TODO: Remove setting object meta 
	#if !data.is_empty():
	#	for key in data:
	#		set_meta(key, data[key])
	
