class_name Generator_Data extends Resource

signal scene_finished(generator : Generator_Data, scene:Node)
signal data_finished(generator : Generator_Data, data:Array)


class Cell_Data extends RefCounted:
	#the grid posistion of the cell
	var coord: Vector2i
	#the layer id of the cell incase there diffrent layers
	var layer_id: int
	#the atlas texture (if) used by the cell
	var texture_coord: Vector2i
	func _init(
			_coord: Vector2i,_texture_coord: Vector2i = Vector2i(),_layer_id: int=0
		) -> void:
		coord = _coord
		layer_id = _layer_id
		texture_coord = _texture_coord
func make_cell_data(
	coord: Vector2i,texture_coord: Vector2i = Vector2i(),layer_id: int=0
)->Dictionary:
	return {
		"coord":coord,"texture_coord":texture_coord,"layer_id":layer_id
	}
	

#this hold base function for a world generator. 
#foilage or world generation are the main goals. but also mazes

#WHAT IF: pass some node to work on and a flag stating a full wipe or standard generation
#also need constrants like bounds. could probably get tile size from map.
#would have a tilemap pass and assume 2d

#NOTE: no need for a bounds since the generator in most cases should be shared
#for a world and thus @export can provide the bounds
#should an array be passed? but too big of a size could be an issue
func generate(scene:Node):
	scene_finished.emit(self,scene)


#an optional one that can use data incase more than one generator need to run
#will use data instead of scene since it should not modify the scene, just the data
func generate_with_data(data: Array):
	data_finished.emit(self, data)
	
#TODO: New system may not modify the data directly
#instead it will provide getter functions to get info from a noise map
#or catched state
##get some data representing the cell at the coord. Base cell data will be base
##on the data needed to make a tile in a tilemap layer
func get_tile_info(coord : Vector2i)->Tile_Info:
	return null
