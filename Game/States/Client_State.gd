class_name Client_State extends State
signal updated()

#currently storing client data in a config file for now
#Since it faster than declaring them here and handling it
#like the other states
#may delare each value here in the future for readiblity
#and could use setters/getters to add directly to reduce loops on save
#and extra memory(? might still reserve the space in memory)
var config_file = ConfigFile.new()

var language_keys: Array[String] = ["en", "es"] #this is a placeholder. may keep it here
#and move it up or have something else handles the ids

static func get_default_instance()-> State:
	return load('uid://bnvrjjacwa30l')

func set_language(index:int = -1) -> String:
	if index >= 0 && index < language_keys.size():
		TranslationServer.set_locale(language_keys[index])
		return language_keys[index]
	return ""

func load_data(data:Dictionary[String,Variant]={})->void:
	print_debug('MEOW LOAD DATA IN CLIENT STATE CALLED')
	var sound_volume = config_file.get_value("sound","music_volume",30)
	var language = config_file.get_value("general","language",OS.get_locale_language())
	var language_index: int = -1
	if language_keys.has(language):
		language_index = language_keys.find(language)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(sound_volume*0.01))
	set_language(language_index)
	super(data)
