class_name Pounce_Fishing_State extends RefCounted

signal start()
signal catched(fish_data:Dictionary)
signal missed()
signal canceled()
signal end()

@export var random_table: Random_Table_Resource = Fish_Table.new()

var action_state : Action_State

func pick_fish()->Dictionary:
	var picked_data : Dictionary = {}
	if random_table == null :
		print_debug('No table assigned')
	else:
		picked_data = random_table.pick_from_table(true)
	return picked_data
