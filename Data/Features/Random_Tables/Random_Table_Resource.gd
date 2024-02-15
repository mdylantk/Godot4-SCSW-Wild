class_name Random_Table_Resource extends Resource

@export var max_weight_per_group : int = 100
@export var table : Array[Weighted_Group_Resource]

func pick_from_table():
	var entries = []
	for group in table:
		var group_roll = randi() % max_weight_per_group
		if group_roll <= group.weight:
			#use this group
			entries = group.entries 
			break
	if not entries.is_empty():
		#pick and element from the table
		return entries.pick_random()
	else:
		return null
