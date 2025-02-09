##This house signals and events that can be used for two object to comunicate\
##indirectly. For an example, a Player controller may be controlled by the player handler
##and any pawn that ref it can listen to input and triggers the the handler sets or calls
class_name Controller extends Resource

##An abstract action call that can be used to send messages and data from contoller host
##to pawn
signal action_triggered(action:String, value:Variant)

##generic signal that may be called when a value here change. Used to let pawn
##know about changes
signal state_change()

##An input direction that may be use to move a pawn in a direction as long as one
##is vaild
@export var direction : Vector2

func trigger_action(action:String, value:Variant):
	action_triggered.emit(action,value)

func set_direction(new_direction:Vector2):
	if new_direction != direction:
		direction = new_direction
		state_change.emit()
