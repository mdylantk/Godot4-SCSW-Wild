class_name Character_State extends Savable_State

#expose this to the resource editor so that some character states can be flagged off
@export var unique : bool = true :
	set(value):
		unique = value
		is_unique = value


##this provides a way to get a save location or return the provided default
##if there is no saved location
func get_location(default_location:Vector2=Vector2(),id:String="position") ->Vector2:
	if has_meta("location"+id):
		return get_meta("location"+id,default_location)
	return default_location
##a helper func that make sure the location id is maintained
func set_location(location:Vector2, id:String="position")->void:
	set_meta("location"+id, location)

#func on_load(data:Variant,id=String):
#	super(data,id)
#	if (data as Dictionary):
#		pass
	#	if "meta" in data:
	#		set_meta_from_dict(data["meta"])
	#if (data as ConfigFile):
	#	if data.has_section_key(id,"meta"):
	#		set_meta_from_dict(data.get_value(id,"meta"))

#func on_save(data:Variant,id=String):
#	super(data,id)
#	if (data as ConfigFile):
#		pass
	#	if save_meta:
	#		data.set_value(id,"meta",get_meta_as_dict())
