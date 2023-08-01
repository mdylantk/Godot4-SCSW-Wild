class_name One_Bit_Tilemap extends TileMap

@export var bounds : Vector2 = Vector2(32,32) #the bounds which generated content may extends to
@export var bounds_offset : Vector2 = Vector2(-16,-16)

func _ready():
	print("chunk loaded:" + str(self))
	#randomize()
	if !y_sort_enabled:
		y_sort_enabled = true #note this override it,but currently y sort is wanted and new tilemaps is not including it
	#if !layer[0].y_sort_enabled:
	#	layer[0].y_sort_enabled = true
	var x = 0
	var y = 0
	while x <= bounds.x:
		while y <= bounds.y:
			
			
			var tile_location = Vector2(x,y) + bounds_offset
			#print(tile_location)
			if get_cell_tile_data(0,tile_location) == null : #&& get_cell_tile_data(1,tile_location) == null && get_cell_tile_data(2,tile_location) == null :
				
				var random_tile = pick_foliage_tile()
				if random_tile != Vector2i.ZERO:
					set_cell(0,tile_location,0,random_tile)
			#must keep below
			y += 1
		y = 0
		#must keep below
		x += 1
		
		#print(Vector2(x,y))
		#if get_cell_tile_data(0,Vector2(x,y)) == null && get_cell_tile_data(2,Vector2(x,y)) == null :
				
		#	set_cell(0,Vector2(x,y),0,Vector2i(1, 1))
func pick_foliage_tile():
	#randi() % 8 #0-7
	#note: could have an array for each type. grass, tree, cover, rocky and others
	#could even have a float or int as an id(like generic weight) maybe add up the weight and rand with that pluss null offset
	#the tree path nice too, just messy. forest-> grass, tree, plain-> grasses, paths, trees
	#there noise that could be used too, but a bit compucated. could draw masks out on the tile map as well, but the theme somewhat compucate that
	if randi() % 10 >= 4:
		if randi() % 10 >= 4:
			return Vector2i(5 + randi() % 3, 0)
		elif randi() % 10 > 6:
			return Vector2i(3 + randi() % 3, 1)
		else:
			return Vector2i(randi() % 6, 1)
	elif randi() % 10 > 4:
		return Vector2i(1 + randi() % 4, 0)
		#5 + randi() % 3 #5 + 0-3 = 5-7
	#if RandomNumberGenerator
	#a temp way to pick random tiles
	return Vector2i(0, 0)
