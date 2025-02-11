class_name Random_Table_Resource extends Resource

@export var max_weight_per_roll : int = 100
@export var fail_weight : int = 0
@export var table : Array[Weighted_Group_Resource]

func pick_from_table(return_details = false):
	#details will return an dictionary of the pick entry and the rarity
	#rarity 0 should also be a null pick
	var entries = []
	var details = {
		"rarity":0,
		"rolls":[],
		"pick":""
	}
	var fail_roll = 0
	if fail_weight > 0:
		fail_roll = randi() % max_weight_per_roll
		details["rolls"].append(fail_roll)
		if fail_roll <= fail_weight: 
			if return_details: return details
			return null
	for group in table:
		var group_roll = randi() % max_weight_per_roll
		details["rolls"].append(group_roll)
		details["rarity"] += 1 #0 only should return if there was a chance tp fail
		if group_roll <= group.weight:
				#use this group
			entries = group.entries 
			break
	if not entries.is_empty():
		#pick and element from the table
		if return_details: 
			details["pick"] = entries.pick_random()
			return details
		return entries.pick_random()
	if return_details: return details
	return null
