class_name Base_Conditional extends Resource

#NOTE: default is the default return value. There may be cases where
#the logic is not handle and it will return the default as the result

func is_true(data:Action_State, default:bool = true) -> bool:
	return _is_true(data,default)

func _is_true(data:Action_State, default:bool = true) -> bool:
	return default
