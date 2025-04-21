class_name Action_On_Interact extends Interactive_Data

@export var action : Base_Action

func _run():
	if action != null:
		data["handler"] = handler
		data["source"] = interactor
		data["target"] = interactee
		action.run(Action_State.new(interactor,interactee))
	end_interact()
