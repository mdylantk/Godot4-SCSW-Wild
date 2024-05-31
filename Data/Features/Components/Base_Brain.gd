class_name Base_Brain extends Resource
#the purpous of this is to isolate the character process logic. More so the
#move on input logic so it can be replace to things like move to point or other
#AI base movement logic. default will return nothing or the movement input vector
#this could also listen to input as well, but it should not need to. the charaters
#can grab data from this if it is hosted here and the AI can set changes

#so beside geting move direction, character should also listen to this for fake input changes.
#or the AI/player controller will handle that, but may limit allowing the brain to handle 
#more independent tasks.
#so it may also need a process/update function that alow it to run its own logic per tick
#or a callable for the character to run if not null. it could also connect to an AI update clock
#but would need a ref to it

func get_move_vector(current_position := Vector2()) -> Vector2:
	return Vector2()
	
func update() -> void :
	pass
