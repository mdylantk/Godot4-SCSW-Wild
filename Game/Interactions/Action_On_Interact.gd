class_name Action_On_Interact extends Interactive_Data

#cont strings to use as keys so they are located at one spot
#const key_end_interact : String = '$end_action'
const KEY_ACTION : String = 'action'
const KEY_ACTION_STATE : String = 'action_state'

@export var action : Base_Action

func _run():
	if action != null:
		var action_state = Action_State.new(interactor,interactee)
		#TODO: decide if action need to be stored
		data[KEY_ACTION] = action
		data[KEY_ACTION_STATE] = action_state
		var vaild_action : bool = action.run(action_state)
		if vaild_action and action_state.is_referred:
			action_state.assign_on_end(func(is_canceled:bool = false):
				end_interact(is_canceled)
			)
			return
		
	end_interact()
