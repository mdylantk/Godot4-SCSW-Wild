@tool
class_name Instance_Data extends Level_Data

#NOTE: Packed scenes are not abstract. will cause a circular dep, so need to load from string
@export_file("*.tscn") var instance_scene : String = "uid://hepasgr3svoi"

##the point to spawn. TODO add a resource to handle this since the point could be fixed
##base on an object, or store in player or world state. also could be an array if there is more
##than one spawn position
@export var spawn_point :Vector2 = Vector2(8,-8)

var loaded_scene : Node

func load_level():
	if loaded_scene == null:
		var scene = load(instance_scene)
		loaded_scene = scene.instantiate()
		level_created.emit(loaded_scene)
	else:
		print_debug("I still have a scene.")

func unload_level():

	level_removed.emit(loaded_scene)
	loaded_scene.call_deferred("queue_free")
	#loaded_scene = null

func get_spawn_position(spawn_index:int=0, handler:Node = null)->Vector2:
	return spawn_point
