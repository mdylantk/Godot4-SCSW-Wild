@tool
class_name HUD extends CanvasLayer

#generic signal that state when a gui scene been update...if said update emit it(placeholder mostly)
#currently no use since most update per process. also children may call their own, but may also call this
#to let others know the object ref so they could connect if needed
signal gui_update(element)

@export var hide_hud : bool = false :
	set(value):
		if value != hide_hud:
			hide_hud = value
			%LoadingScreen.visible = !hide_hud
			%Score.visible = !hide_hud
			%Dialog.visible = !hide_hud
			%Notify.visible = !hide_hud
	get:
		return hide_hud
		
@onready var loading : bool = false :
	set(value):
		if(%LoadingScreen):
			%LoadingScreen.visible = value
	get:
		return %LoadingScreen.visible

#may not be the best, but exposing these so they can be called directly instead of having to look them up
#should only be for more static gui types
@onready var gui_notify = %Notify
@onready var gui_score = %Score
@onready var gui_dialog = %Dialog

@onready var fishing_game = %FishingPondMap

var player_state : Savable_State
var player_pawn 
#func _ready():
	#pass

func _process(_delta):
	if !Engine.is_editor_hint():
		#TODO: have the player handler set a state for this to use
		#so this would need a state to use for player and any other needed states
		if player_state != null:
		#may need a dict for score in playerstate or a function that can fetch it
			var fish_count = player_state.fetch("total_common_fish_caught")
			var rare_fish_count = player_state.fetch("total_rare_fish_caught")
			if fish_count == null: fish_count = 0
			if rare_fish_count == null: rare_fish_count = 0
			if fish_count == 0 and rare_fish_count == 0:
				%Score.update_data()
			elif fish_count > 0 or rare_fish_count > 0:
				if fish_count == null: fish_count = 0
				if rare_fish_count == null: rare_fish_count = 0
				%Score.update_data({"Common":fish_count,"Rare":rare_fish_count})
	
		#this being put here untill a timer or state system can take care of it
		#var player_pawn = Game.get_player_handler().pawn
		if player_pawn != null:


		#testing a way to point back to home
		#print(get_viewport().get_visible_rect().size)
			var current_size = get_viewport().get_visible_rect().size
			if player_pawn != null:
				if player_pawn.global_position.length() > current_size.length() :
					%HomePoint.visible = true
					%HomePoint/TextureRect.position = (-(player_pawn.global_position - Vector2(16*32,16*32))).clamp(Vector2.ZERO, (current_size -Vector2(16,16)))
				#Vector2(16*32,16*32) is the offset. should be the player orginal spawn or the old man global location
				else:
					%HomePoint.visible = false
		

#func loading(is_loading):
	#await get_tree().create_timer(1).timeout #A delay so things can finish up. currrenty need to be appled difftrently or not used
#	$LoadingScreen.visible = is_loading


