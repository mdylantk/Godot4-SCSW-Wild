class_name State extends Resource

##A generic event that notify any listerners
signal notify(type:String, message:Variant)
##Called when a Variant value or certain properties are changed
##TODO: add types and decided if the name is fine since value feels more number like
signal value_changed(property, new_value, old_value)
##Called before the a saving so data can be updated.
signal saving()
##called when data is finished being loaded.
signal loaded()

##Returns a state if a default exists.
static func get_default_instance()-> State:
	return null

##Atempts to convert the pass array into a vector. Type represent the desire vector
##where 0 or less will use the array size to guess it and 5 and above will return
##the vector as a shallow copy. 1 will return it as a float or int base on the as_int
##flag. as_int is used to consider if it a vectori or not. type 2 = Vector2,
##type 3 = Vector3, type 4 = Vector4
static func array_to_vector(vector_array:Array, type:int = 0, as_int:bool = false)->Variant:
	var array = vector_array.duplicate()
	if !array.is_empty():
		if type <= 0:
			type = array.size()
		#make sure the array is the proper size for the next steps
		#and replace all nulls with 0 for all cases of vector conversions
		if array.size() < type:
			for i in range(array.size()):
				if array[i] == null:
					if as_int:
						array[i] = 0
					else:
						array[i] = 0.0
		if type == 0:
			return []
		elif type == 1:
			if as_int:
				return float(array[0])
			return int(array[0])
		elif type == 2:
			if as_int:
				return Vector2i(array[0], array[1])
			return Vector2(array[0], array[1])
		elif type == 3:
			if as_int:
				return Vector3i(array[0], array[1],array[2])
			return Vector3(array[0], array[1], array[2])
		elif type == 4:
			if as_int:
				return Vector4i(array[0], array[1], array[2], array[3])
			return Vector4(array[0], array[1], array[2], array[3])
		else:
			return array
	return []
	
##Attemps to convert the vector into an array. It supports non-packed
##vector types, int, float, and array(will return a shallow copy).
static func vector_to_array(vector:Variant)->Array:
	if typeof(vector) == TYPE_VECTOR2 || typeof(vector) == TYPE_VECTOR2I:
		return [vector.x, vector.y]
	if typeof(vector) == TYPE_VECTOR3 || typeof(vector) == TYPE_VECTOR3I:
		return [vector.x, vector.y,vector.z]
	if typeof(vector) == TYPE_VECTOR4 || typeof(vector) == TYPE_VECTOR4I:
		return [vector.x, vector.y, vector.z, vector.w]
	if typeof(vector) == TYPE_ARRAY:
		#NOTE: this do not check the type
		return vector.duplicate()
	if typeof(vector) == TYPE_FLOAT || typeof(vector) == TYPE_INT:
		return [vector]
	return []


##this will set an id in metadata while also notifing it was changed
func set_data(key: String, value: Variant) -> void:
	var old_value = null
	if has_meta(key):
		old_value = get_meta(key)
	if old_value != value:
		set_meta(key,value)
		value_changed.emit(key, value, old_value)

#NOTE: object meta could be used for the state, but
#the state should handle it in a diffrent way.
#The base stare has this as a way to be used
#without extending it

func is_meta_key_public(id:Variant)->bool:
	if !(id.begins_with("_") || id.begins_with(".")):
		return true
	return false
	
#since we are not going to save this directly, metadata could be extracted instead
#of making our own verion
func get_metadata()->Dictionary[String,Variant]:
	var metadata:Dictionary[String,Variant]
	for id in get_meta_list():
		if is_meta_key_public(id):
			metadata.set(id, get_meta(id))
	return metadata
	
func set_metadata(new_meta:Dictionary[String,Variant])->void:
	for id in new_meta:
		set_meta(id, new_meta[id])

#clear only the vaild savable metadata
func clear_metadata():
	for id in get_meta_list():
		if is_meta_key_public(id):
			remove_meta(id)

##trigger the saving event as well as compile all savable properties into a dict
func fetch_save_data()->Dictionary[String,Variant]:
	saving.emit()
	return {}

##load the data passed and then triggers the loaded event
func load_data(data:Dictionary[String,Variant]={})->void:
	loaded.emit()
