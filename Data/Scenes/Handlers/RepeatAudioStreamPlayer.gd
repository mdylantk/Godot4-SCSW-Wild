extends AudioStreamPlayer

func _on_finished():
	print_debug("trying to repeat music")
	play()
