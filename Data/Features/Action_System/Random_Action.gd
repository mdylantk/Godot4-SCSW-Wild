class_name Random_Action extends Base_Action

@export var actions : Array[Base_Action]

func run(data:={}):
	actions.pick_random().run(data)
