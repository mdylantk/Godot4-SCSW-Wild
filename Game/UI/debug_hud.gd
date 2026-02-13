extends CanvasLayer

@export var enable_debug : bool = false :
	set(value):
		enable_debug = value
		visible = enable_debug

@export var game_state : Game_State = Game_State.get_default_instance()
@export var world_state : World_State = World_State.get_default_instance()
@export var player_state : Player_State = Player_State.get_default_instance()

var ui_message : String

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enable_debug:
		var debug := %Debug
		var camera_global_position : Vector2
		if get_viewport().get_camera_2d() != null:
			camera_global_position = get_viewport().get_camera_2d().global_position
	
		var debug_text = str(camera_global_position)
		debug_text = debug_text + "\n" + "Game Paused: " + str(game_state.pause_state) + "("+str(get_tree().paused)+")"
		debug_text = debug_text + "\n" + "Level loading: " + str(world_state.is_level_loading)
		debug_text = debug_text + "\n" + "time: " + str(game_state.game_time)
		debug_text = debug_text + "\n" + "day percent: " +  String.num(fmod(game_state.game_time/game_state.time_in_day,1.0)*100,2)
		#TODO: If need, then have the game hander expose it or the player state
		#debug_text = debug_text + "\n" + "player input: " + str(!Player.paused)
			#NOTE: this need to change with the new item system. was added with the old to get it working
		#NOTE: may need player or game connect these to signal instead of a direct ref
		#var players:Array[Node] = get_tree().get_nodes_in_group("Player_Pawns")
		debug_text = debug_text + "\n" + ui_message
		if player_state.player_debug_message != '':
			debug_text = debug_text + "\n" + player_state.player_debug_message

		debug.text = debug_text

func _unhandled_input(event:InputEvent):
	if event.is_action_pressed('Debug'):
		enable_debug = !enable_debug
		get_viewport().set_input_as_handled()
