class_name Input_Handler extends Node

@export var enable_input : bool = true 

#NOTE: knowing the handler will allow network vaildation
var player_handler : Player_Handler



#TODO: Player handler should handle network rep. this should handle notifing
#the player of changes in input. may seem a bit redundent ut need a way to split
#input away from the player handler since there could be many
#so this is a short script meant to act as a breaker so only the owning
#client's player handler will fire

func _input(event:InputEvent):
	if !enable_input or player_handler == null: 
		return
	player_handler.input_update(event)
