class_name Character_State extends Savable_State

#NOTE: This might not be used as it was orignally created
#charater will load and save data base on its componets
#and this may be used if additinal stats need their own place
@export var local_position : Vector2
var level : Node #may be better as uid or name
@export var inventory : Array[Item]

#func _reset_state() -> void:
#	super()
	
#func get_save_data()->Dictionary[String,Variant]:
#	return super()
	
#and load will load the pass data (if changed) and then notify
#all that it is ready(aka loaded)
#func load_data(data:Dictionary[String,Variant]=_data)->void:
#	super(data)
