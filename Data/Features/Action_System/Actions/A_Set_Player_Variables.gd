class_name A_Set_Player_Variables extends Base_Action

@export var group : String = "meta"
##NOTE: this need to have string keys
@export var variables : Dictionary

func run(data:={}):
	if data.has("handler"):
		var handler : Player_Handler = data["handler"] as Player_Handler
		if handler == null:
			print_debug("handler is incorrect type")
			return 
		for key in variables.keys():
			handler.state.store(key, variables[key],group)
	else:
		print_debug("no handler")
