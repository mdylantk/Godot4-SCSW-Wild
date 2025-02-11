class_name Environment_Data extends Resource

##for the time handler(aka world) to call.
##NOTE: if there is no handler of this, then this will not be called
##and it will be the holder of this to process the data as needed 
signal time_update(delta:float)

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
	time_update.emit(rate)
		
func get_environment_color()->Color:
	if environment_color == null:
		return Color(day_time,day_time,day_time)
	return environment_color.sample(day_time)
