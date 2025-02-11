extends CanvasLayer
signal close(node:Node)
#var config : ConfigFile
@export var default_focus : Control

#May not be ideal to ref it here, but for now keeping it here for testing and easy refactoring
var config : ConfigFile #= Resources.get_settings(Resources.client_settings_file

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	config = Data.client_state
	#var config = Resources.get_settings(Resources.client_settings_file)
	var volume = Data.client_state.get_value("sound","music_volume",50)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume))
	%Music_Volume_Slider.value = volume
	print_debug("ready")

func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("Start") or event.is_action_pressed("Cancel"):
			close.emit(self)
			get_viewport().set_input_as_handled()

func _on_settings_loaded(id:String, is_new : bool):
	if id == "client_settings":
		var sound_volume = 30
		if is_new:
			if !config: config = ConfigFile.new()
			config.set_value("sound","music_volume",sound_volume)
		else:
			sound_volume = config.get_value("sound","music_volume",sound_volume)
		%Music_Volume_Slider.value = sound_volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(sound_volume*0.01))
	

func _on_music_volume_slider_value_changed(value: float) -> void:
	#Note: value*0.01 reduce the range to 0-1 so 100 is not 100 times loud
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value*0.01))
	#config = Resources.get_settings(Resources.client_settings_file)
	config.set_value("sound","music_volume",value)
	Data.save_settings()
	#Resources.save_settings(Resources.client_settings_file)
	#config.save(Resources.client_settings_file)
	#TODO: add a delay. like add this as a callable var if null and run it latter, nulling and saving the config
		#Resources.save_settings(Resources.client_settings, Resources.client_settings_path)
		
func _on_visibility_changed() -> void:
	if visible and default_focus != null:
		default_focus.grab_focus()
