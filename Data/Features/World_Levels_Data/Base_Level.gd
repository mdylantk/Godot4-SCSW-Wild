class_name Base_Level extends Node

#this may replace world data
#enities are usally contrain to a level and not the world
#controllers would have to decide what can be transfer over. 
#if viewports are understood better, then this may make it easier to transfer
#the reason to switch from resource from node is the level can be design better
#and additional logic can be add (not hard coded) above the map at the cost of
#some node limitation due to its abstraction.

#TODO decide if the it should be a node or node2d or another class

#NOTE will remate level_data here to try to reused world and instance data
#TODO: should create level under itself same with enities
#signal level_created(level:Node)
#signal level_removed(level:Node)
#signal entity_created(entity:Node)
#signal entity_removed(entity:Node)

#this may or maynot be used. could be use as a node
@export var environment_data : Environment_Data
@export var environment_color : CanvasModulate

@export var default_spawn_position : Vector2
@export var use_default_spawn_position : bool = false

##this is a counter for the world handler to know if the level need to be culled
##the world handler will update it as needed (NOTE: also could store as a metadata)
var active_age : int = 1

#TODO: this probably should not be used. can use metadata or directly acess it
#func get_level_property(name:StringName) -> Variant:
#	return null

func is_level_loaded(location:Vector2)->bool:
	return true

#either use a string or an int for the spawn location id
#int is less readable, smaller, and probably quicker
#but both cases require looking in the level data to know what is avalible
#but default is return if not used. could also plug in an enum to level transfer
#and aggree to reserve the index for the enum amount and anything else is extra
#handler is pass incase it need a stored position
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
	
func _ready() -> void:
	get_tree().call_group(
		"Players", "relocate_pawn", default_spawn_position
	)

	World.world_update.connect(_on_world_update)

##NOTE: this is a temp solution, but basicly the level should either listen
##to world update or periodicly check the world time state and update its own
##environment. The level should handle itself, but the world is for keeping some
##global setting connected
##TODO: have a diffrent function that pass data about the time state and handle
##time base on a float (0-1) so the world can keep a global time and the float
##is the point in day.
func _on_world_update() -> void:
	if environment_data != null and environment_color != null:
		environment_data.forward_time()
		environment_color.color = environment_data.get_environment_color()
