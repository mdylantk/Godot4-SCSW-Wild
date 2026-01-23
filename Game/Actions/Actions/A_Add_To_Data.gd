class_name A_Add_To_Data extends Base_Action

##The dictionary keys should ne Strings. 
@export var addtional_data : Dictionary[String,Variant]

func _run(action_state:Action_State) -> bool:
	for key in addtional_data.keys():
		action_state.set_data(key,addtional_data[key])
		#data[key] = addtional_data[key]
	return super(action_state)
