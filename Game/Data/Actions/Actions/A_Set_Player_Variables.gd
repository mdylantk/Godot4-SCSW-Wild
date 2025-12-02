class_name A_Set_Player_Variables extends Base_Action

@export var group : String = "meta"
##NOTE: this need to have string keys
@export var variables : Dictionary
@export var player_state : Player_State = load('uid://c67c2fehtuhni')

func _run(data:Action_State = null) -> bool:
	#var handler := Player
	#if handler == null:
	#	print_debug("handler is incorrect type")
	#	return false
	for key in variables.keys():
		#NOTE: This is old and may need to change
		#since the state may have fix varibles
		#and this only covers the abstract ones
		player_state.set_data(key,variables[key])
		#handler.save_state.set_value(key,variables[key])
		#print_debug("MEOW! This is outdated and save_state may be used instead. also get/set value instead of meta")
		#handler.state.set_meta(key,variables[key])
		#handler.state.store(key, variables[key],group)
	#else:
	#	print_debug("no handler")
	return super(data)
