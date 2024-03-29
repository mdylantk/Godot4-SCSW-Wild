class_name Instance_Data extends Level_Data

@export_file("*.tscn") var instance_scene : String = "res://Data/Scenes/Maps/InstanceTest.tscn"

var loaded_scene : Node
var ref

func load_level():
	if loaded_scene == null:
		#NOTE: there may be a way to get a preloaded one?
		if ref == null:
			ref = load(instance_scene)
		loaded_scene = ref.instantiate()
		level_created.emit(loaded_scene)
	else:
		print_debug("I still have a scene.")

func unload_level():

	level_removed.emit(loaded_scene)
	loaded_scene.call_deferred("queue_free")
	#loaded_scene = null
	
