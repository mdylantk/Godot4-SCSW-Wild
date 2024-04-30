class_name Dialog_Group extends Resource

@export var group_name: String
@export var is_random: bool = false
@export var segments: Array[Dialog_Segment]
#note: should keep track of the current segment id and group name in dialog data
#so that the action can grab a ref to the text. also could just pass the text
#so no acientnal circle dep happens

#NOTE: could have child segments so there could be one for random element
#but require a getter function. current system fine, but may require serveral
#segment for each random option
func get_segment(index=0,ignore_random:bool=false)-> Dialog_Segment:
	if is_random and !ignore_random:
		return segments.pick_random()
	elif index < 0 or index > segments.size():
		print_debug("Warning, index is invaild. returning at index 0")
		return segments[0]
	else:
		return segments[index]

## return of the index is consider the last of the segment. if random will return true
func is_at_end(index:int=0)-> bool:
	if is_random: return true
	if index+1 >= segments.size():
		return true
	return false
