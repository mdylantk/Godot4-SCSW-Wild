class_name C_Compare_Properties extends Base_Conditional

#NOTE: this wont work for inventory or nested types. 
#also wont check var of objects unless exposed here. 
##How the two values will be compared. Warning: some won't work with some types
##and there currently no error protection for those cases
@export_enum("==","!=",">=","<=","<",">") var comparison : int
#Note, could have game and world
@export_enum("handler","source","target","player","data") var property_source : String
@export var property_name : String
##will always check metadata if source is a node, else use metadata
@export var always_use_metadata_of_nodes : bool 
@export var values_to_compare : Array #will use an array since can not export variant
#will be treated as an and comparison

func _is_true(data:Action_State = null, default:bool=true) -> bool:
	#if null, would return false
	var value : Variant
	var source : Variant
	if data == null:
		return false
	#checking for world and game since they may be added later
	if property_source == "data":
		value = data.get_data(property_name,null)
		#if !data.has_meta(property_name):
		#	return false
		#value = data.get_meta(property_name)
	elif property_source != "game" and property_source != "world" and property_source != "player":
		if !data.has_meta(property_source):
			print_debug("source is not included")
			return false
		source = data.get_meta(property_source)
	elif property_source == "game":
		#NOTE: using state instead of handler so
		#lots of these need to be updated
		source = load('uid://cnbeqfpaumxj3')
	elif property_source == "world":
		source = load('uid://b047ftosxvj7p')
	elif property_source == "player":
		#pass #Note: need to use the player state
		source = load('uid://c67c2fehtuhni')
	if always_use_metadata_of_nodes:
		if (source as Node) == null:
			print_debug("source is not node and thus may not have metadata")
			return false
		value = source.get_meta(property_name,null)
	else:
		if property_source == "handler":
			
			#TODO: check for state else do as below
			pass
		#note: need dedicated way to acess the states
		#since they are moving to a more typed storage
		if source is Player_State:
			if source.has_meta(property_name):
				value = source.get_meta(property_name)
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
