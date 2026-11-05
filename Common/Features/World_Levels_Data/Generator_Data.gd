class_name Generator_Data extends Resource
	
#TODO: New system may not modify the data directly
#instead it will provide getter functions to get info from a noise map
#or catched state
##get some data representing the cell at the coord. Base cell data will be base
##on the data needed to make a tile in a tilemap layer
func get_tile_info(coord : Vector2i, masks:Array = [])->Tile_Info:
	return null
	
func get_connection_id(coord: Vector2i, tile_width:int=16, tile_height:int=16, masks:Array = [])->int:
	return -1
