class_name A_Add_To_Data extends Base_Action

##The dictionary keys should ne Strings. 
@export var addtional_data : Dictionary

func run(data:={}):
	for key in addtional_data.keys():
		data[key] = addtional_data[key]
