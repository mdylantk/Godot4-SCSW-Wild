#NOTE: may keep this for the action system or level use
#but any state that save it should try to get it as an array
#or dictionary
class_name Exit_Data extends Resource

#NOTE: there are cases where the levels are base on the same scene
#but generated diffrently. it may be better to have the target scene and 
#data related to how it spawns in
#NOTE: above is old and world state might be used for that case
#not sure if target level is needed. also exit data might be better
#for the world or character state depending on what handles it and
#how multiplayer may need to handle it(for practice)
##the level before this exit data
@export var previous_level : String:
	set(value):
		previous_level = value
		data.set('previous_level', value)
	get:
		return data.get('previous_level',target_level)

##The level that is being traveled to
@export var target_level : String:
	set(value):
		previous_level = target_level
		target_level = value
		data.set('level', value)
	get:
		return data.get('level',target_level)

#TODO: need more data for above. need to know the level load list
#since it could be a sub-level so it need the level and each sublevel
#or a id for the level to generate it
#spawn data will be used for that, but may or may not be used for this project
#NOTE: may use metadata for spawn_data. just need to extract it if it needs saving
@export var spawn_data: Dictionary[String,Variant] :
	set(value):
		spawn_data = value
		data.set('spawn_data', value)
	get:
		return data.get('spawn_data',spawn_data)


#an possibly way to spawn at a point of a node or a store position
@export var spawn_point_id : String:
	set(value):
		spawn_point_id = value
		data.set('spawn_point', value)
	get:
		return data.get('spawn_point',spawn_point_id)
		
@export var override_entry_position : bool = false :
	set(value):
		override_entry_position = value
		data.set('override_entry_position', value)
	get:
		return data.get('override_entry_position',override_entry_position)

#may or may not provide a spawn point id
#if provied. than this would act as an offset
##the offset position for the new level
@export var entry_position : Vector2:
	set(value):
		entry_position = value
		data.set('entry_position', [value.x,value.y])
	get:
		var vector : Array = data.get('entry_position',[entry_position.x,entry_position.y])
		return Vector2(vector[0],vector[1])

##the position from the old level before exiting
@export var previous_position : Vector2:
	set(value):
		previous_position = value
		data.set('previous_position', [value.x,value.y])
	get:
		var vector : Array = data.get('previous_position',[previous_position.x,previous_position.y])
		return Vector2(vector[0],vector[1])
		
#not sure if direction is the character non-facing direction
#or some position around the entry. so it might not be used
#NOTE: not sure if this is needed. entry velocity would be used for movement 
#and could use enrty position to change position around the spawn point
#the transfer action also can add options to convert triggering direction
#to the entry position(TODO: Probably should rename it entry offset
#and maybe add a flag(and vector) to directly override position
#could change this to offset and a flag to override position
@export var entry_offset : Vector2:
	set(value):
		entry_offset = value
		data.set('entry_offset', [value.x, value.y])
	get:
		var vector : Array = data.get('eentry_offset',[entry_offset.x,entry_offset.y])
		return Vector2(vector[0],vector[1])

##The facing direction the pawn should used on entry
@export var facing_direction : Vector2:
	set(value):
		facing_direction = value
		data.set('facing_diection', [value.x, value.y])
	get:
		var vector : Array = data.get('facing_direction',[facing_direction.x,facing_direction.y])
		return Vector2(vector[0],vector[1])
#there may be a case where the character will slide through an exit
#or something similar, so this would be used
##the velocity to apply when entring level.
@export var entry_velocity : Vector2 :
	set(value):
		entry_velocity = value
		data.set('entry_velocity', [value.x, value.y])
	get:
		var vector : Array = data.get('entry_velocity',[entry_velocity.x,entry_velocity.y])
		return Vector2(vector[0],vector[1])

var data: Dictionary[String,Variant]
#other data may be added to metadata if needed, but if it is used enough,
#then it should be delared here
