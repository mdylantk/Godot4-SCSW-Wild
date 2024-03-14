#@tool
class_name NewTestMap extends TileMap


#NOTE: this is a test
@export var test_Region: Region_Data = Region_Data.new()


@export var update_test : bool = false

func test():
	if test_Region != null:
		var region_size = int(test_Region.region_size*test_Region.region_size)
		var chunk_size = int(test_Region.chunk_size*test_Region.chunk_size)
		for chunk_id in range(region_size):
			for tile_id in range(chunk_size):
				#test_Region.region_data[chunk_id][tile_id]
				#need the chunk x,y for rendering test
				var chunk_x = chunk_id%int(test_Region.region_size)
				var chunk_y = floor(chunk_id/test_Region.region_size)
				var test_location=test_Region.get_region_coords(tile_id,chunk_id)
				var random_tile = Vector2i(6,12)
				if int(chunk_x)%2 == 0 and  int(chunk_y)%2 == 0:
					random_tile = Vector2i(6,11)
				elif int(chunk_x)%2 == 1 and int(chunk_y)%2 == 1:
					random_tile = Vector2i(6,10)
				elif int(chunk_x)%2 == 0 and int(chunk_y)%2 == 1:
					random_tile = Vector2i(6,9)
				elif int(chunk_x)%2 == 1 and int(chunk_y)%2 == 0:
					random_tile = Vector2i(6,8)
				set_cell(0,test_location,0,random_tile)
				#set_cell(0, location, 0, Vector2i(1,1))

#set_cell (
# 0, Vector2i coords, 0, Vector2i.ZERO 
#)

# Called when the node enters the scene tree for the first time.
func _ready():
	test()
	set_cell(0,Vector2i(0,0))
	var test = test_Region.get_tile_id(Vector2i(16,16))
	var test2 = test_Region.get_chunk_id(Vector2i(16,16))
	var test_location = test_Region.get_region_coords(test,test2)
	set_cell(0,test_location)
#	pass # Replace with function body
	print(test_Region.get_tile(test_location))
	test_Region.set_tile(test_location, "meowing tile")
	print(test_Region.get_tile(test_location))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
