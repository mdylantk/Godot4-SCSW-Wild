##A base class for storing data. Exported values will be saved
##if saving with ResourceSaver. Owning node is responsible for the
##save/load logic with ResourceSaver. This can be used as is with set/get
##value, or can be extended upon.
class_name Savable_State extends Resource

##Called when a Variant value or certain properties are changed
signal value_change(property, new_value, old_value)
##Called when on_save is called
signal saving()
##called when on_load is called. NOTE: it use is unlikly
##unless using a custum save/load that do not create a new state
##on load. Then this will let listers to update with the new data.
signal loaded()


#NOTE: only exported values will be saved (with ResourceSaver)
##Variant Values data. A String keyed dictionary of Variants
##Should be limited to types safe to save to tres/res files
@export var _data : Dictionary = {}

##Check if there a variant value by the provided key
func has_value(key:String)-> bool:
	return _data.has(key)

##Erase a value. For cases where the value is not needed anymore
func erase_value(key)->bool:
	return _data.erase(key)

##Get a variant value in the state
func get_value(key:String, default:Variant = null) -> Variant:
	if _data.has(key):
		return _data[key]
	return default

##Set a variant value in the state
func set_value(key: String, value: Variant) -> void:
	var old_value = get_value(key)
	_data[key] = value
	if value != old_value:
		value_change.emit(key,value, old_value)


##this should be called before saving the state
##it should emit saving so other objects can update
##the state
func on_save()->void:
	saving.emit()

##This is called when load_save_data is ever called
func on_load()->void:
	loaded.emit()
	
##This is to fetch a dictionary of savable data
##for cases where one wants to use a diffrent save method
##instead of resource saver
func get_save_data()-> Dictionary:
	return {"_data":_data}

##This is to load the state form the provided data
func load_save_data(data:Dictionary) -> void:
	_data.clear()
	if data.has("_data"):
		_data = data["_data"]
	on_load()
