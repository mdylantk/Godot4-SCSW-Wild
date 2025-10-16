extends AudioStreamPlayer

func _on_finished():
	print_debug("trying to repeat music")
	play()

#test to load the music dynamily
func get_music_files(path:String,prefix:String) -> PackedStringArray:
	var dir := DirAccess.open(path)
	var files := PackedStringArray()
	if (dir):
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		print_debug(dir.get_files())
		for file_name in dir.get_files():
		#while file_name != String():
			#print_debug(file_name.to_lower(), file_name.to_lower().begins_with(prefix),file_name.get_extension() ,file_name.get_extension() in ['ogg','mp3','wav'])
			if (file_name.to_lower().begins_with(prefix) and
				file_name.get_extension() in ['ogg','mp3','wav']
			):
				
				var file_path = path + '/'+ file_name
				#print_debug(file_path)
				if (ResourceLoader.exists(file_path)):
					files.append(file_path)
				else:
					#Not sure about this, so need to test if this 
					#works with non-pc builds
					if FileAccess.file_exists(file_path +'.remap'):
						files.append(file_path)
					elif path.begins_with('user'):
						files.append(file_path)
			#file_name = dir.get_next()
		#dir.list_dir_end()
	return files
	
func load_music():
	#will not check for doubles for now since this is a test
	var game_music_paths = get_music_files('res://Game/Data/Assets/Music','background')
	var player_music_paths = get_music_files('user://Music','background')
	var all_music_paths = game_music_paths + player_music_paths
	print_debug(all_music_paths)
	var stream_as_randomizer := stream as AudioStreamRandomizer
	for path in all_music_paths:
		if path.begins_with('user'):
			var file_data = FileAccess.open(path,FileAccess.READ)
			if !file_data:
				print_debug('unable to open file')
				continue
						#Note handling as mp3, but should add the other types
			var file_mp3 = file_data.get_buffer(file_data.get_length())
			file_data.close()
			var audio_stream = AudioStreamMP3.new()
			audio_stream.data = file_mp3
			stream_as_randomizer.add_stream(-1,audio_stream)
		else:
			var loaded_stream = ResourceLoader.load(path)
			stream_as_randomizer.add_stream(-1,loaded_stream)
		#print_debug(loaded_stream)
		print_debug(path,' | ', stream_as_randomizer.streams_count)
	

func _ready() -> void:
	load_music()
	play()
	pass
