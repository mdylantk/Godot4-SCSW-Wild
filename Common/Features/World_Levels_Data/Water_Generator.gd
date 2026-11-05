class_name Water_Generator extends Generator_Data

@export var water_map : Noise = FastNoiseLite.new()

@export var water_level : float = 0.0

@export var water_tile : Tile_Info

#a circle mask with a soild inner(mask[2])2 and a fading outter (mask[3]) radius
func get_mask_value(coord: Vector2i,mask=[0,0,0,0]) -> float:
	var x = coord.x - mask[0]
	var y = coord.y - mask[1]

	var distance = sqrt(x * x + y * y)
	if distance <= mask[2]:
		return 1.0

	if distance >= mask[3]:
		return 0.0

	return  1.0 - ((distance - mask[2])/ (mask[3] - mask[2]))
	
func get_masks_value(coord: Vector2i, masks:Array):
	var value = 0
	for mask in masks:
		value = max(value, get_mask_value(coord, mask))
	return value

func get_connection_id(coord: Vector2i, tile_width:int=16, tile_height:int=16, masks:Array = [])->int:
	#TODO: need to have it pass a something that can be used to offset the water level so static chunks and maybe 
	#random chucks wont need to worry about messing up water
	var check_point = Vector2i(coord.x-tile_width,coord.y-tile_height)
	var nw = water_map.get_noise_2d(check_point.x,check_point.y) + get_masks_value(check_point,masks)*2 <= water_level
	check_point.x = coord.x
	check_point.y = coord.y-tile_height
	var n= water_map.get_noise_2d(check_point.x,check_point.y) + get_masks_value(check_point,masks)*2 <= water_level
	check_point.x = coord.x+tile_width
	check_point.y = coord.y-tile_height
	var ne= water_map.get_noise_2d(check_point.x,check_point.y) + get_masks_value(check_point,masks)*2 <= water_level
	check_point.x = coord.x+tile_width
	check_point.y = coord.y
	var e= water_map.get_noise_2d(check_point.x,check_point.y) + get_masks_value(check_point,masks)*2 <= water_level
	check_point.x = coord.x+tile_width
	check_point.y = coord.y+tile_height
	var se= water_map.get_noise_2d(check_point.x,check_point.y) + get_masks_value(check_point,masks)*2 <= water_level
	check_point.x = coord.x
	check_point.y = coord.y+tile_height
	var s= water_map.get_noise_2d(check_point.x,check_point.y) + get_masks_value(check_point,masks)*2 <= water_level
	check_point.x = coord.x-tile_width
	check_point.y = coord.y+tile_height
	var sw =water_map.get_noise_2d(check_point.x,check_point.y) + get_masks_value(check_point,masks)*2 <= water_level
	check_point.x = coord.x -tile_width
	check_point.y = coord.y
	var w= water_map.get_noise_2d(check_point.x,check_point.y) + get_masks_value(check_point,masks)*2 <= water_level
	
	var id = 0
	if (nw):
		id |= 1;
	if (n):
		id |= 2;
	if (ne):
		id |= 4;
	if (e):
		id |= 8;
	if (se):
		id |= 16;
	if (s):
		id |= 32;
	if (sw):
		id |= 64;
	if (w):
		id |= 128;
	
	return water_tile.connection[id]

func connection_pos(id, width=8):
	var tile= Vector2i(
		id % width,
		floor(id / width)
	);
	return tile



func get_tile_info(coord : Vector2i, masks:Array = [])->Tile_Info:
	var height = water_map.get_noise_2d(coord.x,coord.y) + get_masks_value(coord,masks)*2
	if height > water_level:
		return null
	return water_tile

	
	
