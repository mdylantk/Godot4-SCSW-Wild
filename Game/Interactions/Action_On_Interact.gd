class_name Action_On_Interact extends Interactive_Data

@export var action : Base_Action

func _run():
	if action != null:
		var action_state = Action_State.new(interactor,interactee)
		data["action"] = action
		data["action_state"] = action_state
		action.run(action_state)
	end_interact()
