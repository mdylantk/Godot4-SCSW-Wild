class_name Player_State extends Savable_State

#func _init():
	#metadata = {
	#	"total_common_fish_caught":0,
	#	"total_rare_fish_caught":0,
	#	"fish_caught":{},#rarity_name:amount or metadata. if metadata, could store addital data like turn in amount with current amount
	#	"unquie_fish_locations":[], #world and local fish spawn
	#} #placeholer that can store dynamic vars

var pawn #NOTE: this should be the pawn class or a savable data struct for rebuilding the pawn
var world_position : Vector2 #this should be set when traveling or saving. global_position should be used
#for the actual position
var instance = null #the instance the player is in. mostly for loading reasons. 
var instance_position : Vector2 #similar to world position, but used when loading into an instance
#so set when saving or before loading into an instance from world. (but instance may override it coded that way)

var scores : Dictionary = {}

#TODO: it is unlikly there be more than one location to store of the player state
#and if there more than one "world" each can have a dedicted varible or the others
#can be added as a meta
#var world_location : Vector2

func set_score(id:String, new_score: int)->void:
	var old_score = 0
	if id in scores:
		old_score = scores[id]
	scores[id] = new_score
	property_changed.emit(id+"_score",new_score,old_score)
	
func get_score(id:String)->int:
	if id in scores:
		return scores[id]
	return 0
	
func on_load(data:Variant,id:String):
	super(data,id)
	if (data as ConfigFile):
		if data.has_section_key(id,"scores"):
			scores = data.get_value(id,"scores")

func on_save(data:Variant,id:String):
	super(data,id)
	if (data as ConfigFile):
		data.set_value(id,"scores",scores)
