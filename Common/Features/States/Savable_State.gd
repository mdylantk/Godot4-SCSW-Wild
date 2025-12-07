##A base class for storing data. Exported values will be saved
##if saving with ResourceSaver. Owning node is responsible for the
##save/load logic with ResourceSaver. This can be used as is with set/get
##value, or can be extended upon.
class_name Savable_State extends State

@export var data : Dictionary[String,Variant] = {}

#TODO: all bit set_value is unnessaru since dicts has their own way
#set is to allow notifications of change. also not deleting atm
#since things may still be calling it
##Check if there a variant value by the provided key
func has_value(key:String)-> bool:
	return data.has(key)

##Erase a value. For cases where the value is not needed anymore
func erase_value(key)->bool:
	return data.erase(key)

##Get a variant value in the state
func get_value(key:String, default:Variant = null) -> Variant:
	return data.get(key,default)

##Set a variant value in the state
func set_value(key: String, value: Variant) -> void:
	var old_value = get_value(key)
	data[key] = value
	if value != old_value:
		value_changed.emit(key,value, old_value)

#NOTE: TODO: below may not be used in savable state since
#it is ment to be save as is. may need to keep some to transfer metadata to data
#to be save, but metadata should not be used that way for this resource.
#also set and get values are not useful either. state has set_data, but savable 
#state should not be listen to normally(it created to catch and save to disk or
#load from disk and fetched from)

func _reset_state() -> void:
	data.clear()
	
#keeping this to trigger save and load logic
#save will tell all that it about to compress data into
#something savable or when it self is going to be saved
func fetch_save_data()->Dictionary[String,Variant]:
	saving.emit()
	return data
	

#and load will load the pass data (if changed) and then notify
#all that it is ready(aka loaded)
func load_data(new_data:Dictionary[String,Variant]=data)->void:
	data = new_data
	loaded.emit()

func _init(new_data : Dictionary[String,Variant] = data) -> void:
	data = new_data
