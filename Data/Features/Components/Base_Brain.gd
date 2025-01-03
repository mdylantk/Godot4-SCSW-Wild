class_name Base_Brain extends Resource
##ask for the controller/character(or listerner) that it would like to do an action.
##This action usally an input event triggers like attack or interact
##NOTE:this a concept and may or may not be used(and most likly renamed)
signal character_action_request(id:StringName)

#TODO: decide oh handling actions. this could hold function or send signals related
#to actions. since this may be a responce script, the actions may be abstract
#for example if we want it to 'attack' objects tagged 'enemies' that is a tile away or closer
#would need a trigger function that allow metadata or a conflict object
#the brain will try to process it if it have such a case
#then either return a value or emit a signal
#later may be ideal since it might catch data and trigger it when conditions are
#ment. this also means it may need to run logic on the process or the character
#would need to call it enough times (but not too much) to make sure it updated

#NOTE also can use child classes of brain to store static data on interaction
#so character can check if brain that type and then work with that data.
#The base brain dose not need to cover all cases. it just need to provide basic 
#navigation tools so the character dose not have to caculate it. so move in direction
#which can be improve to move to direction in children. nav pathing probably can be handle
#in children as well


@export var _direction : Vector2

##Set a fixed direction. Could be input axis of the controller, the
##look direction of the character, or a fixed direction to move
func set_direction(direction:Vector2=Vector2())->void:
	_direction = direction

##This allows the brain to override the direction.
##should be called before the move logic
func get_direction(
		position:Vector2, velocity:Vector2=Vector2()
	)->Vector2:
	return _direction

#should be called from a timer or owning node. it ment to run checks to deicide actions
#so it should not need to run often. usally when a change is made or to similate reaction time of AI
##This may not be needed. parent or handler should set stuff here and it should update
##as needed. 
func update(pawn:Node2D = null, handler: Controller_Handler = null) -> void :
	#print_debug("meowing " + str(pawn))
	pass
