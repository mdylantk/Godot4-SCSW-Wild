extends AudioStreamPlayer

func _on_finished():
	print_debug("trying to repeat music")
	play()

func _ready() -> void:
	#NOTE: since the stream is being updated at the start of the game,
	#autoplay may not work. so far calling play works, but may need to
	#have data notify that it is finish patching. idealy as long as data_handler
	#is created before this, then this should be good enough
	#but may need a sound event or state if godot do not have a way to pause and
	#resume it without direct acess to the node
	play()
