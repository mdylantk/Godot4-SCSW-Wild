class_name Environment_Data extends Resource

@export var day_time : float
@export var sun_rise : bool
@export var environment_color : Gradient

func forward_time(rate:float=0.01)->void:
	if day_time >= 1:
		sun_rise = true
	elif day_time <= 0:
		sun_rise = false
	if sun_rise:
		day_time -= rate
	else:
		day_time += rate
func get_environment_color()->Color:
	if environment_color == null:
		return Color(day_time,day_time,day_time)
	return environment_color.sample(day_time)
