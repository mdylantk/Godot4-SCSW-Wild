##This is another way to save data instead of resource or config.
##like config, it will hold the data and then save it state. The data
##is exposed and the load/save functions can be change
##The idea is to save it as a binary(data) or json(not added yet) depending
##if readability is needed. 
class_name Save_File extends RefCounted

#Note: may use config file for now unless this way is needed
#NOTE: could try to improve secuirty of loading of config files
#by looking for the risks. probably blacklist func may be enough?
#need to save a script to see the formate. also may need to check paths
#but that be extra work and may make loading slow

var _data : Dictionary = {}

func get_sections() -> Array[String]:
	return _data.keys()
	
func erase_section(section: String) -> bool:
	return _data.erase(section)
	
func has_section(section: String) -> bool:
	return _data.has(section)
	
	
func get_section_keys(section:String) -> Array[String]:
	if _data.has(section):
		return _data[section].keys()
	return []
	
func erase_section_key(section: String, key: String) -> bool:
	if _data.has(section):
		return _data[section].erase(key)
	return false
	
func has_section_key(section: String, key: String) -> bool:
	if _data.has(section):
		return _data[section].has(key)
	return false
	
func set_value(section: String, key: String, value: Variant) -> void:
	if !_data.has(section):
		_data[section] = {}
	_data[section][key] = value
	
func get_value(section:String, key:String, default:Variant = null ) -> Variant:
	if _data.has(section):
		if _data[section].has(key):
			return _data[section][key]
	return default
	
func clear()->void:
	_data.clear()

func load(path:String)->Error:
	var file = FileAccess.open(path,FileAccess.READ)
	if file:
		_data = file.get_var()
		file.close()
		return 0
	return 1
	
func save(path:String)->Error:
	var file = FileAccess.open(path,FileAccess.WRITE)
	if file:
		file.store_var(_data)
		file.close()
		file = null
		return 0
	return 1
