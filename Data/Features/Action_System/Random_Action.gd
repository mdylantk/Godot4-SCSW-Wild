class_name Random_Action extends Base_Action

@export var actions : Array[Base_Action]

func run(data:Action_Data = null) -> bool:
	return actions.pick_random().run(data)
