extends CharacterMovement
signal hit(pawn)

func on_interact(handler, instigator, interactee, data):
	hit.emit(self)
	print("MEOWOW!")
