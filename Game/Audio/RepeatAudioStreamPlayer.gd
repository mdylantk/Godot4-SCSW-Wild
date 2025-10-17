extends AudioStreamPlayer

func _on_finished():
	print_debug("trying to repeat music")
	play()

#test to load the music dynamily
#func get_music_files(path:String) -> PackedStringArray:
	#var dir := DirAccess.open(path)
	#var files := PackedStringArray()
	#if (dir):
		#dir.list_dir_begin()
	#	#var file_name = dir.get_next()
	#	print_debug(dir.get_files())
	#	for file_name in dir.get_files():
	#		var file_ext := file_name.get_extension()
	#		if (file_ext in ['ogg','mp3','wav']):
	#			var file_path = path + '/' + file_name
	#			if (ResourceLoader.exists(file_path)):
	#				files.append(file_path)
	#			else:
	#				#Not sure about this, so need to test if this 
	#				#works with non-pc builds
	#				if FileAccess.file_exists(file_path +'.remap'):
	#					#file_path = file_path + '.remap'
	#					files.append(file_path)
	#				elif path.begins_with('user'):
	#					files.append(file_path)
	#return files
	
func load_music():
	#will not check for doubles for now since this is a test
	#var game_music_paths = get_music_files('res://Game/Data/Assets/Music/Background')
	#var player_music_paths = get_music_files('user://Data/Music/Background')
	#using Data_Handler for getting the files since this logic may move there
	#or part of it
	var paths = Data_Handler.get_files(
		['res://Game/Data/Assets/Music/Background',
			'user://Data/Music/Background'],
		['ogg','mp3','wav']
		)
	print_debug(paths)
	var stream_as_randomizer := stream as AudioStreamRandomizer
	for path in paths:
		if path.begins_with('user'):
			var file_ext := path.get_extension()
			var file = FileAccess.open(path,FileAccess.READ)
			if !file:
				print_debug('unable to open file')
				continue
						#Note handling as mp3, but should add the other types
			var file_data = file.get_buffer(file.get_length())
			file.close()
			var audio_stream : AudioStream
			if (file_ext == 'mp3'):
				audio_stream = AudioStreamMP3.new()
			elif (file_ext == 'wav'):
				audio_stream = AudioStreamWAV.new()
			elif (file_ext == 'ogg'):
				audio_stream = AudioStreamOggVorbis.new()
			audio_stream.data = file_data
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
