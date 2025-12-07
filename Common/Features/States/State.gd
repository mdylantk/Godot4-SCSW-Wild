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

##this will set an id in metadata while also notifing it was changed
func set_data(key: String, value: Variant) -> void:
	var old_value = null
	if has_meta(key):
		old_value = get_meta(key)
	if old_value != value:
		set_meta(key,value)
		value_changed.emit(key, value, old_value)

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
