class_name Random_Action extends Base_Action

@export var actions : Array[Base_Action]

func _run(data:Action_State = null) -> bool:
	return actions.pick_random().run(data)
