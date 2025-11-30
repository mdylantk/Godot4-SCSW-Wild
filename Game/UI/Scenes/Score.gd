extends CanvasLayer


@export var text_template := "{id}: {score}"

#these are here so the values can be change in one spot
var state_section:String = "States"
var state_key:String = "player"
#todo: use player state and listen to score
@export var state : Player_State = load('uid://c67c2fehtuhni') :
	set(value):
		if value != state:
			var old_state = state
			state = value
			connect_to_state(old_state)
			return
		state = value
		
func connect_to_state(old_state = null):
	print_debug("MEOW HANDLING STATE", state)
	if old_state :
		state.score_changed.disconnect(on_score_changed)
		state.loaded.disconnect(on_state_loaded)
	if state :
		state.score_changed.connect(on_score_changed)
		state.loaded.connect(on_state_loaded)
		update_score()
			

func set_common_score(value:int) -> void:
	if %Score_0 == null:
		print_debug('called before everything is ready')
		return
	%Score_0.visible = value != 0
	set_score(%Score_0,"Common",value)
func set_rare_score(value:int) -> void:
	if %Score_1 == null:
		print_debug('called before everything is ready')
		return
	%Score_1.visible = value != 0
	set_score(%Score_1,"Rare",value)

func set_score(label:Label, id:String, score:int):
	label.text = text_template.format({"id": id, "score": score})
	visible = (%Score_0.visible || %Score_1.visible)

#NOTE: old display logic. the score system itself a bit static. may need a leaderboard like system
func update_score():
	var common_fish_count : int = state.get_score("common_fish_caught")
	var rare_fish_count : int = state.get_score("rare_fish_caught")
	set_common_score(common_fish_count)
	set_rare_score(rare_fish_count)

func on_state_loaded()->void:
	print_debug("MEOW LOADED WAS CALLED")
	update_score()

func on_score_changed(key:String, new_value:int)->void:
	print_debug("|",key,"|",new_value,"|")
	update_score()
	
func _ready() -> void:
	connect_to_state()
