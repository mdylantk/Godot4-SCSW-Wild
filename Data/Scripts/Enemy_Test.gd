class_name EnemyTest extends Character2D
signal hit(pawn)

#NOTE:Interact componet should be used, but this may be fine for quick interactions
#func on_interact(handler, instigator, interactee, data):
	#TODO: add a hitbox logic that acts similar to interact, but handle damage
	#could also hace interact handles it, but may make objects that can be attack
	#and interactive with harder to work with. though collsion masks chould be change
	#so actions are listen on diffrent objects
#	if visible:
#		on_attacked(instigator, interactee, data)
#		#hit.emit(self)
#		print_debug("MEOWOW!")

func _ready() -> void:
	_on_visibility_changed()
	#if brain == null:
	#	brain = AI_Controlled_Brain.new()
	#var players:Array[Node] = get_tree().get_nodes_in_group("Player_Pawns")
	#if players.size() > 0:
		#var player = players[0]
		#brain.set_meta(&"move_to",player)
		#brain.update(player)
	

func _on_visibility_changed() -> void:
	%CollisionShape2D.set_deferred("disabled",!visible)
		#%CollisionShape2D.disabled = visible
