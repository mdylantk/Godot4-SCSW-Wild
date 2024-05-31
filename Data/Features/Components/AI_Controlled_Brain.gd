class_name AI_Controlled_Brain extends Base_Brain

#note this class is a simple AI and might not use navigation. children of this may

##the point id the AI will try to reach. 
@export var point_id : int = 0
##the points the AI could move to. 
@export var move_to_points : Array[Vector2]

#may have a type use a simple object and set the metadata so multi characters
#can share it. no real reason to make a dedicated type unless one want to make all
#the classes needed to make it easier to read. controller can listen to brain for
#info they discover and add to data (or brain can modify data directly) if needed
#var shared_data : Resource

var move_to_location : Vector2

#NOTE: multi points might be best as a metadata? a bit risky for types, but the other option
#is to use a function or object that handles varibles that the brain may need to know about to make
#decisions. such as targets and points of intrest caculated by the AI or a group leader
#NOTE also using metadata may be a pain? since it be harder to listen to so a setter function
#may be easier and could be improved if metadata appears too bulky. but the object idea may be best
#then only a ref to it is needed and the brain will only need to store data base on itself
#TODO: decide on how this object(well maybe a resource) should function so that function expose 
#here could be simpified or removed could have set location remove if the object handles it
##set the location the AI will move to.
func set_move_to_location(new_location := Vector2()) -> void:
	move_to_location = new_location

func get_move_vector(current_position := Vector2()) -> Vector2:
	return Vector2(current_position.direction_to(move_to_location))
