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

#NOTE: lots of these are part of the brain. may need to rename it for what it is
#or use a signal. for example this would be input vector and the signal will emit
#when there a change. the signal is optional. it can fetch it from the controll or
#controller state. NOTE: a state ref may be ideal, but this can handle the getter.
#also means the controller handler can manage the setters. just need a comunication channel
#here to allow it
func set_direction(new_direction:Vector2):
	if new_direction != direction:
		direction = new_direction
		state_change.emit()
