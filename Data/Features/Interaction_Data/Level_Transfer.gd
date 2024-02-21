class_name Level_Transfer extends Interactive_Data

@export var level_data : Level_Data_2D

func interact(handler, instigator, interactee, data):
	if level_data != null:
		print_debug("meow loading level data")
		General_Events.change_level(level_data, handler)
	else:
		print_debug("no level data")
	super(handler, instigator, interactee, data)

	
