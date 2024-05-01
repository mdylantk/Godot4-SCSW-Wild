class_name C_Compare_Properties extends Base_Conditional

#NOTE: this wont work for inventory or nested types. 
#also wont check var of objects unless exposed here. 
##How the two values will be compared. Warning: some won't work with some types
##and there currently no error protection for those cases
@export_enum("==","!=",">=","<=","<",">") var comparison : int
#Note, could have game and world
@export_enum("handler","source","target","data") var property_source : String
@export var property_name : String
##will always check metadata if source is a node, else use metadata
@export var always_use_metadata_of_nodes : bool 
@export var values_to_compare : Array #will use an array since can not export variant
#will be treated as an and comparison

func is_true(data:={})->bool:
	#if null, would return false
	var value : Variant
	var source : Variant
	#checking for world and game since they may be added later
	if property_source == "data":
		if !data.has(property_name):
			return false
		value = data[property_name]
	elif property_source != "game" and property_source != "world":
		if !data.has(property_source):
			print_debug("source is not included")
			return false
		source = data[property_source]
	elif property_source == "game":
		source = Game
	elif property_source == "world":
		source = World
	if always_use_metadata_of_nodes:
		if (source as Node) == null:
			print_debug("source is not node and thus may not have metadata")
			return false
		value = source.get_meta(property_name,null)
	else:
		if property_source == "handler":
			if source is Player_Handler:
				value = source.state.fetch(property_name)
			#TODO: check for state else do as below
			pass
	if comparison > 1:
		if value == null: return false
	for compare_value in values_to_compare:
		if comparison > 1:
			if compare_value == null: return false
			if typeof(value) != typeof(compare_value):
			#type diffrences can cause issues
				return false
		match comparison:
		#("==","!=",">=","<=","<",">")
			0:
				if value != compare_value:
					return false
			1:
				if value == compare_value:
					return false
			2:
				if !(value >= compare_value):
					return false
			3:
				if !(value <= compare_value):
					return false
			4:
				if !(value < compare_value):
					return false
			5:
				if !(value > compare_value):
					return false
	return true
