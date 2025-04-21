class_name Action_Group extends Base_Action

#NOTE: This will run all vaild actions as long as
#the conditions are met.

@export_enum("AND","OR") var comparison:int
@export var conditions : Array[Base_Conditional]
@export var actions : Array[Base_Action]

const comparison_state: Array[bool] = [true,false]

func _run(data:Action_State = null) -> bool:
	var is_true:bool = comparison_state[comparison]
	for condition:Base_Conditional in conditions:
		if comparison == 0:
			if !condition.is_true():
				break
		elif comparison == 1:
			if condition.is_true():
				is_true = true
				break
	if is_true:
		for action:Base_Action in actions:
			action.run(data)
	return super(data)
