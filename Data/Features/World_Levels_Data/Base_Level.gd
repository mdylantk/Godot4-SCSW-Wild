class_name Base_Level extends Node

#UPDATE TODO: since the level will be a sibling of the handlers (as the current scene)
#it wont be directly handled. This means can do what it pleases. The world wont know
#what the level is except for a node. the level should set world/evioment data and listen
#to world event to stay sync with the world. 
#TODO: make sure the level assign evioment data or at least listen to world clock 
#and update as needed.
@export var environment_data : Environment_Data :
	set(value):
		if environment_data != value:
			if environment_data:
				environment_data.time_update.disconnect(on_time_update)
			if value:
				value.time_update.connect(on_time_update)
			environment_data = value
@export var environment_color : CanvasModulate

@export var default_spawn_position : Vector2
@export var use_default_spawn_position : bool = false

##this is a counter for the world handler to know if the level need to be culled
##the world handler will update it as needed (NOTE: also could store as a metadata)
##DEPRECATED the would would not know this. only a single current level will be loaded
##so it should be unload as it switches. levels could add such a feature with sublevels,
##but it could be handle better.
var active_age : int = 1

#TODO: this probably should not be used. can use metadata or directly acess it
#func get_level_property(name:StringName) -> Variant:
#	return null

func is_level_loaded(location:Vector2)->bool:
	return true

#TODO: level should called to world and stated vaild positions or send a list of 
#object representing a spawn point. this works for now but world should noy assume a level will have this
#also could pass to the player handler, but world may be able to handle network stuff better
func get_spawn_position(spawn_index:int=0, handler:Node = null)->Vector2:
	if use_default_spawn_position:
		return default_spawn_position
	return Vector2()


#Note: maybe have this be called directly in nodes that need to dynamily add and remove
#func map_added(level:Node):
##	add_child(level)
	
#func map_removed(level:Node):
#	level.call_deferred("queue_free")


func get_level_scene(position:Vector2) -> Node:
	return null
	pass
	


##NOTE: this is a temp solution, but basicly the level should either listen
##to world update or periodicly check the world time state and update its own
##environment. The level should handle itself, but the world is for keeping some
##global setting connected
##TODO: have a diffrent function that pass data about the time state and handle
##time base on a float (0-1) so the world can keep a global time and the float
##is the point in day.
func on_time_update(delta:float):
	environment_color.color = environment_data.get_environment_color()
