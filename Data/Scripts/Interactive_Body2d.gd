
class_name Interactive_Body2d extends StaticBody2D

@export var interact_data : Interactive_Data

func on_interact(target):
	
	if interact_data != null:
		interact_data.interact(target,self)
