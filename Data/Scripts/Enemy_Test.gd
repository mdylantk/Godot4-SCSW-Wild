extends Character2D
signal hit(pawn)

func on_interact(handler, instigator, interactee, data):
	on_attacked(instigator, interactee, data)
	#hit.emit(self)
	print_debug("MEOWOW!")
