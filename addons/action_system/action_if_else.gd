class_name Action_If_Else extends Base_Action

@export var condition : Base_Conditional
@export var true_action : Base_Action
@export var false_action : Base_Action

func _run(data:Action_State) -> bool:
	var is_true = false
	if condition != null : 
		is_true = condition.is_true(data)
	if is_true:
		if true_action == null : return false
		true_action.run(data)
	else:
		if false_action == null : return false
		false_action.run(data)
	return super(data)
