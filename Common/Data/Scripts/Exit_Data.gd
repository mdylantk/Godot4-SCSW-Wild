class_name Exit_Data extends Resource

#NOTE: there are cases where the levels are base on the same scene
#but generated diffrently. it may be better to have the target scene and 
#data related to how it spawns in
var target_level : String #uid or path
#TODO: need more data for above. need to know the level load list
#since it could be a sub-level so it need the level and each sublevel
#or a id for the level to generate it
#spawn data will be used for that, but may or may not be used for this project
var spawn_data: Dictionary[String,Variant]


var entry_position : Vector2
var entry_diection : Vector2
var facing_direction : Vector2
#there may be a case where the character will slide through an exit
#or something similar, so this would be used
var entry_velocity : Vector2

#other data may be added to metadata if needed, but if it is used enough,
#then it should be delared here
