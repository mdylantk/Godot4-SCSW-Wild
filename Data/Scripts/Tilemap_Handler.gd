##this is to handle tilemap layers and expose some globlly with keywords(tag) or id
class_name Tilemap_Handler extends Node2D

@export var layers:Array[TileMapLayer]
@export var layers_id:Array[String]


func get_tilemap_layer(index:int)->TileMapLayer:
	return null
	
func get_tilemap_layer_by_id(id:String)->TileMapLayer:
	return null
	
#todo add a way to check if a time is modifyable
#should provided the change type and layer effected
#and this should check the layers that may block it

func is_tile_modification_blocked(pos:Vector2i, tags:Array[String] = [])->bool:
	return false
