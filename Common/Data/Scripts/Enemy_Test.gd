class_name EnemyTest extends Character2D

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
		
func get_move_direction()->Vector2:
	return %Brain.get_move_direction(position, velocity)
