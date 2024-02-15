@tool
class_name Fish_Table extends Random_Table_Resource
#this is a test. Rare fish should be location base or distance base
#so another system would need to pick between two table. the rare one
#with a list limited to a certain area

func _init():
	if table.is_empty():
		table.append(Weighted_Group_Resource.new("common",99,
		[
			"Carp",
			"Koi",
			"Bass",
			"Eel",
			"Barb",
			"Pike",
			"Perch",
			"Salmon",
			"Guppy",
			"Walleye",
			"Trout"
		]
		))
		table.append(Weighted_Group_Resource.new("rare",100,
		[
			"Rainbow Trout",
			"Moon Koi",
			"Black Bass",
			"Silver Guppy",
			"Shadow Pike",
			"Orange Eel",
			"Fade Barb",
			"King Walleye",
			"Killer Salmon",
			"Triple Perch",
			"Apple Carp",
			"Snake Eel", 
			"Doom Pike"
		]
		))
