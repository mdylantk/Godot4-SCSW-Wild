class_name Base_Brain extends Resource
##ask for the controller/character(or listerner) that it would like to do an action.
##This action usally an input event triggers like attack or interact
##NOTE:this a concept and may or may not be used(and most likly renamed)
signal action_triggered(id:String, value:float)

##called when the AI or Player host plans on freeing it from memory
##may not be called but if it dose, then the charaters that owns this should remove
##it from ref
signal removed()

#NOTE: Brain may have a controller. the brain is the decision maker componente
#and decided on if an action should be done (beside simple reaction).
#NOTE: It may need acess to the character state or require manual connections 
#to certain values changes
#TODO: if add a ref to the character state, then decide if it should be treated as
#read only. there may be cases where this would want to modify the state, so I am not sure.
#NOTE: may be able to pass the state in a update call or any call. since the checks
#are driven by functon call. thing like actions are usally remote calls and the character
#would handle direct calls by calling to the brain or directly.
#in short the brain would handle a lot of these caculations
#NOTE: the brain can be unquie. the controller is the only one that need to be shares

@export var _direction : Vector2

func trigger_action(id:String, value:float)->void:
	action_triggered.emit(id, value)
	
func remove()->void:
	removed.emit()

#NOTE: this is for simple cases where it want to travel a fixed direction
#can be used to add a back and forth between walls. more advance brains would
#caculate direction base on the provided data/state and the brain goals
#such as moving between points. In the case of navigation, it may need to get a point
#instead of a direction. this would be the direction plus location for simple cases
func set_direction(direction:Vector2=Vector2())->void:
	_direction = direction


func get_direction(
		_position:Vector2, _velocity:Vector2=Vector2(),_data:Dictionary={}
	)->Vector2:
	return _direction

##Get a point to nav to.
func get_move_to_position(
		_position:Vector2, _velocity:Vector2=Vector2(),_data:Dictionary={}
	)->Vector2:
		return get_direction(_position,_velocity,_data) + _position

#should be called from a timer or owning node. it ment to run checks to deicide actions
#so it should not need to run often. usally when a change is made or to similate reaction time of AI
##This may not be needed. parent or handler should set stuff here and it should update
##as needed. 
func update(pawn:Node2D = null, handler: Controller_Handler = null) -> void :
	#print_debug("meowing " + str(pawn))
	pass
