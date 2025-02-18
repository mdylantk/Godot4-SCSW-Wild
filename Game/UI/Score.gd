extends CanvasLayer


@export var text_template := "{id}: {score}"

#these are here so the values can be change in one spot
var state_section:String = "States"
var state_key:String = "player"
var state : Savable_State :
	set(value):
		if value != state:
			if state != null :
				state.property_changed.disconnect(on_data_change)
				#state.data_changed.disconnect(on_data_change)
			if value != null :
				state.property_changed.connect(on_data_change)
			state = value

func set_common_score(value:int) -> void:
	%Score_0.visible = value != 0
	set_score(%Score_0,"Common",value)
func set_rare_score(value:int) -> void:
	%Score_1.visible = value != 0
	set_score(%Score_1,"Rare",value)

func set_score(label:Label, id:String, score:int):
	label.text = text_template.format({"id": id, "score": score})
	visible = (%Score_0.visible || %Score_1.visible)

#NOTE: old display logic. the score system itself a bit static. may need a leaderboard like system
func update_score():
	#NOTE: GUI may ask for handler or listen for handler, since there little reason
	#for game or anything else to acces HUD. HUD ment to observe all and act like input
	#var common_fish_count = Savedata_Helper.fetch_player_score(Player,"common_fish_caught")
	#var rare_fish_count = Savedata_Helper.fetch_player_score(Player,"rare_fish_caught")
	#if state == null : return
	#var common_fish_count : int = state.fetch("common_fish_caught","scores",0)
	var common_fish_count : int = Savedata_Helper.fetch_player_score(Player,"common_fish_caught")
	#var rare_fish_count : int = state.fetch("rare_fish_caught","scores",0)
	var rare_fish_count : int = Savedata_Helper.fetch_player_score(Player,"rare_fish_caught")
	set_common_score(common_fish_count)
	set_rare_score(rare_fish_count)

func on_data_change(key, new_value, old_value)->void:
	print_debug("|",key,"|",old_value,"|",new_value,"|")
	update_score()
	
func on_save_state_change(section:String, key:String, value:Variant)->void:
	if state_section == section and state_key == key:
		state = value as Savable_State
	update_score()
			
			

func on_save_state_ready()->void:
	if Data.save_state.has_section_key(state_section,state_key):
		state = Data.save_state.get_value(state_section,state_key) as Savable_State
	update_score()
	Player.state.property_changed.connect(on_data_change)

#NOTE: using this again since the notify system broke on save change
#not using fetch or store on the state, so only getting values from the properties
#(maybe)
#func _process(delta: float) -> void:
#	update_score()
	
func _ready() -> void:
	Data.save_state_change.connect(on_save_state_change)
	Data.save_state_ready.connect(on_save_state_ready)
