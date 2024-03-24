class_name NewTestMap extends TileMap


#NOTE: this is a test
@export var test_Region: Region_Data = Region_Data.new()


@export var update_test : bool = false

func test():
	if test_Region != null:
		var region_size = int(test_Region.region_size*test_Region.region_size)
		var chunk_size = int(test_Region.chunk_size*test_Region.chunk_size)
		for chunk_id in range(region_size):
			await get_tree().create_timer(.1).timeout
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
				#set_cell(0,test_location,0,random_tile)
				#set_cell(0, location, 0, Vector2i(1,1))
				var noise_point = noise.get_noise_2d(test_location.x,test_location.y)
				if noise_point > 0.3:
					#NOTE id not working? haveto use 0 since it not using 1
					###NOTE: the reasonis becasue this was loading from regional data
					#so just need to update how it store data
					set_cell(0,test_location,1,Vector2i(2,1))
					#set_cell(0,test_location,0,Vector2i(8,5))
				else:
					set_cell(2,test_location,0,random_tile)

#set_cell (
# 0, Vector2i coords, 0, Vector2i.ZERO 
#)
func generator_test():
	#this could work for water, but needing a array of 2d may make it difficult
	#or need to generate before hand. which slow things down. could have two passes
	#whereit generates by chucks, then manually connect chunks as they load.
	#and between regions it could do similar(just need the logic in world so they
	#know about each other)
	#NOTE: It may  be best to handle the water manually. just need data
	#the smallest is 2x2 and extions can only extend with 2x2. extending ones need
	#the corner pieces. can get nice to know if water then check if tileable
	var cells := []
	var water_cells := {}
	for x in range(128):
		for y in range(128):
			var noise_point = noise.get_noise_2d(x,y)
			if noise_point > 0.2:
				cells.append(Vector2(x,y))
				#water_cells[Vector2(x,y)] = 0
			
	set_cells_terrain_connect(0,cells,1,0)
				


var noise := FastNoiseLite.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	noise.seed = 100
	#await get_tree().create_timer(5.0).timeout
	#generator_test()
	#add_layer(1)
	#set_cell(-1,Vector2i(0,0),0,Vector2i(1,1))
	return #disable tests
	await test()
	set_cell(0,Vector2i(0,0))
	var test = test_Region.get_tile_id(Vector2i(16,16))
	var test2 = test_Region.get_chunk_id(Vector2i(16,16))
	var test_location = test_Region.get_region_coords(test,test2)
	#set_cell(0,test_location)
#	pass # Replace with function body
	#print(test_Region.get_tile(test_location))
	#test_Region.set_tile(test_location, "meowing tile")
	#print(test_Region.get_tile(test_location))
	#return
	await copy_to_region()
	#await get_tree().create_timer(1.0).timeout
	print("copy")
	await get_tree().create_timer(1).timeout
	print("clear")
	#clear()
	print("waiting")
	await get_tree().create_timer(5).timeout
	print("running")
	await paste_from_region()
	print("paste")


#NOTE: below are examples. populating region data could be similar, but truth
#is that the loops should be remaid without callable. ideally in a generator 
#object. the paste can stay here, but may be best using an array and the 
#process brance
func copy_to_region(delay:float = 0.1):
	for chunk_id in test_Region.region_size*test_Region.region_size:
		test_Region.call_on_all_tiles_in_chunk(
	#test_Region.call_on_all_tiles(
			func(region_coords):
				var layer_data := []
				for layer in range(get_layers_count()):
					var tile_data := [
						get_cell_source_id(layer, region_coords),
						get_cell_atlas_coords(layer, region_coords),
						get_cell_alternative_tile(layer, region_coords)
						]
					layer_data.append(tile_data)
				if layer_data  != null:
					test_Region.set_tile(region_coords, layer_data )
		,chunk_id)
		await get_tree().create_timer(delay).timeout
	#print(test_Region.region_data)
	#TODO: loop through the tile map base on the region bounds
	#get tile data and post it to the region data
	#get_cell_tile_data()

	
func paste_from_region(delay:float=0.1):
	for chunk_id in test_Region.region_size*test_Region.region_size:
		test_Region.call_on_all_tiles_in_chunk(
	#test_Region.call_on_all_tiles(
			func(region_coords):
				var layer_data = test_Region.get_tile(region_coords)
				if layer_data != null:
					for layer in range(layer_data.size()):
						var tile_data = layer_data[layer]
						set_cell(layer,region_coords, tile_data[0], tile_data[1], tile_data[2])
		,chunk_id)
		await get_tree().create_timer(delay).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
