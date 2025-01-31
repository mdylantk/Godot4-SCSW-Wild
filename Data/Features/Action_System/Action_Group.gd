class_name Action_Group extends Base_Action
#will extends base action since works the same as an action
#may be a bit odd since it also call actions. if it becomes an issue,
#then it can be made its own type

@export_enum("AND","OR") var comparison:int
@export var conditions : Array[Base_Conditional]
@export var actions : Array[Base_Action]

const comparison_state: Array[bool] = [true,false]
#NOTE: this is ment to be an abstract action.
#it could have a contion and action
#if condition is true, then action can run

#simply if all contion is true (if and) or one is true(if or) the run all actions
func run(data:Action_Data = null) -> bool:
	var is_true:bool = comparison_state[comparison]
	for condition:Base_Conditional in conditions:
		if comparison == 0:
			if !condition.is_true():
				print_debug("conditions is false")
				break
		elif comparison == 1:
			if condition.is_true():
				is_true = true
				break
	if is_true:
		for action:Base_Action in actions:
			action.run(data)
	return super(data)
