class_name A_Set_Player_Variables extends Base_Action

@export var group : String = "meta"
##NOTE: this need to have string keys
@export var variables : Dictionary

func run(data:Action_Data = null) -> bool:
	var handler := Player
	#if handler == null:
	#	print_debug("handler is incorrect type")
	#	return false
	for key in variables.keys():
		handler.state.set_meta(key,variables[key])
		#handler.state.store(key, variables[key],group)
	#else:
	#	print_debug("no handler")
	return super(data)
