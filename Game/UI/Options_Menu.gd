extends CanvasLayer
signal close(node:Node)

@export var default_focus : Control

#May not be ideal to ref it here, but for now keeping it here for testing and easy refactoring
#var config : ConfigFile #= Resources.get_settings(Resources.client_settings_file

var language_keys: Array[String] = ["en", "es"] #this is a placeholder. may keep it here
#and move it up or have something else handles the ids

func set_language(index:int = -1) -> String:
	if index >= 0 && index < language_keys.size():
		TranslationServer.set_locale(language_keys[index])
		return language_keys[index]
	return ""
	
func load_settings() -> void:
	var sound_volume = 30
	var language : String = OS.get_locale_language()
	var language_index : int = -1
	sound_volume = Data.client_state.get_value("sound","music_volume",sound_volume)
	language = Data.client_state.get_value("general","language",language)
	if language_keys.has(language):
		language_index = language_keys.find(language)
	%Music_Volume_Slider.value = sound_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(sound_volume*0.01))
	%Language_OptionButton.select(language_index)
	set_language(language_index)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()
	print_debug("ready")

func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("Start") or event.is_action_pressed("Cancel"):
			close.emit(self)
			get_viewport().set_input_as_handled()


func _on_music_volume_slider_value_changed(value: float) -> void:
	#Note: value*0.01 reduce the range to 0-1 so 100 is not 100 times loud
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value*0.01))
	#config = Resources.get_settings(Resources.client_settings_file)
	Data.client_state.set_value("sound","music_volume",value)
	Data.save_settings()
	#Resources.save_settings(Resources.client_settings_file)
	#config.save(Resources.client_settings_file)
	#TODO: add a delay. like add this as a callable var if null and run it latter, nulling and saving the config
		#Resources.save_settings(Resources.client_settings, Resources.client_settings_path)
		
func _on_visibility_changed() -> void:
	if visible and default_focus != null:
		default_focus.grab_focus()

func _on_language_option_button_item_selected(index: int) -> void:
	Data.client_state.set_value("general","language",set_language(index))
	Data.save_settings()
