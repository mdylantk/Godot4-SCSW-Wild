class_name Player_State extends Resource

@export var metadata = {
	"total_common_fish_caught":0,
	"total_rare_fish_caught":0,
	"fish_caught":{},#rarity_name:amount or metadata. if metadata, could store addital data like turn in amount with current amount
	"unquie_fish_locations":[], #world and local fish spawn
} #placeholer that can store dynamic vars
