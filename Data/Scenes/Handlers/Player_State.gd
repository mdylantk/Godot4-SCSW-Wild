class_name Player_State extends State_Resource

#func _init():
	#metadata = {
	#	"total_common_fish_caught":0,
	#	"total_rare_fish_caught":0,
	#	"fish_caught":{},#rarity_name:amount or metadata. if metadata, could store addital data like turn in amount with current amount
	#	"unquie_fish_locations":[], #world and local fish spawn
	#} #placeholer that can store dynamic vars

var pawn
var world_position : Vector2 #this should be set when traveling or saving. global_position should be used
#for the actual position
var instance = null #the instance the player is in. mostly for loading reasons. 
var instance_position : Vector2 #similar to world position, but used when loading into an instance
#so set when saving or before loading into an instance from world. (but instance may override it coded that way)
