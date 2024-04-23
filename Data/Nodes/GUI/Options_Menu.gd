extends CanvasLayer

#var config : ConfigFile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var config = Resources.get_settings(Resources.client_settings_file)
	var volume = config.get_value("sound","music_volume",30)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume))
	%Music_Volume_Slider.value = volume

func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("Start") or event.is_action_pressed("Cancel"):
			visible = false
			get_viewport().set_input_as_handled()

func _on_settings_loaded(id:String, config: ConfigFile, is_new : bool):
	if id == "client_settings":
		var sound_volume = 30
		if is_new:
			config.set_value("sound","music_volume",sound_volume)
		else:
			sound_volume = config.get_value("sound","music_volume",sound_volume)
		%Music_Volume_Slider.value = sound_volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(sound_volume))
	

func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	var config = Resources.get_settings(Resources.client_settings_file)
	config.set_value("sound","music_volume",value)
	Resources.save_settings(Resources.client_settings_file)
	#config.save(Resources.client_settings_file)
	#TODO: add a delay. like add this as a callable var if null and run it latter, nulling and saving the config
		#Resources.save_settings(Resources.client_settings, Resources.client_settings_path)
		
