class_name Data_Handler extends Node


##will emit when certain save state changes accure. This is not enforced, so not\
##all changes will trigger this.
#NOTE: saving will be handle by the game. this will handle patching 
#and such
signal save_state_change(section:String, key:String, value:Variant)
signal save_state_ready()

##this is the key used for the default encryption. The main point of this key
##is to make the save file not easy to read instead. 
@export var default_key : String = "lock"

##this is the default path where save files will be stored
##Note: mostly client and server data would be saved here
##save games should be stored in subdirectories in this path
@export var default_path : String = "user://"

##asset and mod path are dir that will be used for runtime loading/patching
##This is the project path for data
@export var data_path : String = "res://Game/Data/"
##this is the user path for data. Note this is for pathcing/adding to
##the project (if logic is added) and not a proper modding system
@export var patch_path : String = "user://Data/"

##This is the default name for the save dir. For games that allow
##more than one save, this will be changed on new or save game ui events
#@export var save_name : String = "Default"
#config files will be handle directly and will follow "type".cfg or
#"type"_config.cfg. like client.cfg and game.cfg
#@export var client_config: String = "client_config"
@export var background_music_stream : AudioStreamRandomizer = preload('uid://bba37ge2fakbi')

#will use the game state for path info
#and will try to move save and load and stuff there as well
#data my stay for patching
@export var game_state : Game_State = load('uid://cnbeqfpaumxj3')
@export var client_state : Client_State= load('uid://bnvrjjacwa30l')

##the default object for saving data realted to the current game save
#var save_state : ConfigFile
##The object for storing settings
#var client_state : ConfigFile

##The main use of this is to make sure there is a dir. This will create
##the dir pase on the path which will allow new saves to be created without an error
static func secure_path(path:String)->Error:
	if !DirAccess.dir_exists_absolute(path):
		return DirAccess.make_dir_recursive_absolute(path)
	return OK

##Get all files in a directory matching the extensions if given
##for user patching and runtime loading of data.
static func get_files(
		paths:Array[String],vaild_extension:Array[String]=[]
	) -> PackedStringArray:
	var dir : DirAccess
	var files := PackedStringArray()
	for path in paths:
		dir = DirAccess.open(path)
		if (!dir): continue
		for file_name in dir.get_files():
			var file_ext := file_name.get_extension()
			if (file_ext in vaild_extension || vaild_extension.is_empty()):
				var file_path = path + '/' + file_name
				#note: may or may not need to check for .remap
				files.append(file_path)
	return files

func get_save_path():
	return game_state.get_save_path()
	#return default_path+"/"+save_name+"/"
##This will try to save the provide object to disk
func save_data(
	state:Object,file_name:String="Save",path:String=default_path,encrypted:bool=false,key:String=default_key
	)->Error:
		var full_path = path+"/"+file_name
		Data_Handler.secure_path(path)
		if (state as ConfigFile) or (state as Save_File):
			if encrypted:
				return state.save_encrypted_pass(full_path+".save",key)
			else:
				return state.save(full_path+".cfg")
		elif state as Resource:
			if encrypted:
				return ResourceSaver.save(state, full_path+".res")
			else:
				return ResourceSaver.save(state, full_path+".tres")
		else:
			print_debug("State is not a vaild type")
		return 1
		
##This mostly a helper function since resource load diffrent from other
##objects. Save works, but load have to be handle diffrently
func load_resource(
	file_name:String="Saved",path:String=default_path,encrypted:bool=false
	) -> Resource:
		var full_path = path+"/"+file_name
		if encrypted:
			if ResourceLoader.exists(full_path+".res"):
				return ResourceLoader.load(full_path+".res","",0)
		else:
			if ResourceLoader.exists(full_path+".tres"):
				return ResourceLoader.load(full_path+".tres","",0)
		return null
		
##This will try to load a file from disk if the provide object have a way to be loaded
func load_data(
	state
	:Object,file_name:String="Save",path:String=default_path,encrypted:bool=false,key:String=default_key
	)->bool:
		#NOTE: may need to manually update the existing state unless
		#there is a way to patch it or override it
		
	var full_path = path+"/"+file_name
	if (state as ConfigFile) or (state as Save_File):
		if encrypted:
			if FileAccess.file_exists(full_path+".save"):
				state.load_encrypted_pass(full_path+".save",key)
				return true
		else:
			if FileAccess.file_exists(full_path+".cfg"):
				state.load(full_path+".cfg")
				return true
	else:
		print_debug("State is not a vaild type")
	return false


##Save the client settings so autosave would not be needed for settings
func save_settings():
	save_data(client_state.config_file,"settings",default_path,false)

func load_music():
	var paths = Data_Handler.get_files(
		[data_path + 'Assets/Music/Background',
			patch_path + '/Music/Background'],
		['ogg','mp3','wav']
		)
	#print_debug(paths)
	for path in paths:
		if path.begins_with('user'):
			var file_ext := path.get_extension()
			var file = FileAccess.open(path,FileAccess.READ)
			if !file:
				#print_debug('unable to open file')
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
			background_music_stream .add_stream(-1,audio_stream)
		else:
			var loaded_stream = ResourceLoader.load(path)
			background_music_stream .add_stream(-1,loaded_stream)
		#print_debug(path,' | ', background_music_stream .streams_count)

#var test:Resource = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_music()
	#TODO: save state may not be used
	#also may use a dedicated state for client state, but
	#save like the other
	#save_state = ConfigFile.new()
	#TODO: client state should be handle by the game or player handler
	#since it should turn into a proper state
	#client_state = ConfigFile.new()
	load_data(client_state.config_file,"settings",default_path,false)
	print_debug("ready")
	client_state.updated.connect(save_settings)
