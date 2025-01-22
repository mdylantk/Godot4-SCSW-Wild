extends Tilemap_Handler


func _ready() -> void:
	%Player.brain = Player.controller_brain
	var player_pos = Player.state.fetch("old_man_house","positions")
	if typeof(player_pos) == TYPE_VECTOR2:
		%Player.position = player_pos
