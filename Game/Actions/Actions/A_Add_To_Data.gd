class_name A_Add_To_Data extends Base_Action

##The dictionary keys should ne Strings. 
@export var addtional_data : Dictionary[String,Variant]

func _run(data:Action_State = null) -> bool:
	for key in addtional_data.keys():
		data.set_meta(key,addtional_data[key])
		#data[key] = addtional_data[key]
	return super(data)
