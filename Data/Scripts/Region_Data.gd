@tool
class_name Region_Data extends Resource
#this will hold data for generating a region(tilemap)
#from chunks of tile data or something similar
#the idea is to have as little memory overhead as possible
#so nested arrays are being used instead of nested object or dictionaries
#chunk data should be a varible type so what call this can assume it's structure
#due not that could cause issue if region data become hard saved. the idea is to
#have a static tilemap for areas and use this for tilemaps that are generated
#foilage would need to be handle diffrently on static maps unless static map data
#is preloaded as region data, but this would add overhead when loading it
#maybe could have a tilemap that compile the data at build time that will be used
#to generate the map, but at chunk gen level so foilage can be added. this would
#allow the tilemap to be unmodified(in other words the tilemap will be used as a
#template): this still means the map would need to be generated with static tilemaps
#but allow diffrent elements with diffrent seeds. also could try to add logic to
#tilemaps so that when they run, they pick their tiles from provided data
#but this may require using tilemaps as is and may require recreating tilemaps
#instead of reusing existing tilemaps. due note reusing have the cost of loading 
#templates in memory so a way to unload it would be needed

#NOTE: Seems when populated wirh Tile_Info, there almost no memory change.
#and this is on all loaded tilemaps for the tesy(at least 9). so most of the overhead
#is the tilemaps. may be able to use a tile data or even chunk data. the issue
#is that the tile_info is the same for each entry
@export var region_data : Array
#@export var region_location: Vector2
#sizes should be fixed else systems could fall apart due to an unwanted change
#also may need tike dim or set tile need to have caller precaculate location
#const region_size : Vector2 = Vector2(8,8)
#const chunk_size : Vector2 = Vector2(16,16) 
const region_size : int = 8
const chunk_size : int  = 16

#TODO: below should be using region coord to fetch a tile or chunk, not world
#so chunks would be grabing a big tile, and a tile is a small tile in that chunk
static func get_tile_id(region_coords:Vector2i):
	var tile_coords : Vector2i = Vector2i(region_coords.x%chunk_size,region_coords.y%chunk_size)
	var tile_id = region_coords.x%chunk_size + (region_coords.y%chunk_size)*chunk_size
	return tile_id
	
static func get_chunk_id(region_coords:Vector2i):
	var chunk_coords :Vector2i = region_coords / chunk_size
	var chunk_id = chunk_coords.x + chunk_coords.y*region_size 
	return chunk_id

static func get_region_coords(tile_id:int = 0, chunk_id:int = 0):
	var tile_location:Vector2i = Vector2i(
		tile_id%int(chunk_size),
		floor(tile_id/chunk_size)
		)
	return tile_location + (get_chunk_coords(chunk_id) * chunk_size)
	
static func get_chunk_coords(chunk_id:int=0):
	var chunk_location:Vector2i = Vector2i(
		chunk_id%int(region_size),
		floor(chunk_id/region_size)
		)
	return chunk_location 

func _init():
	pass
	#region_data.resize(region_size*region_size)
	#so either test logic with null check or use a smaller pool size
	#if region_data.is_empty():
	#	for chunk_id in range(region_size*region_size):
	#		region_data.append([])
	#		for tile_id in range(chunk_size*chunk_size):
	#			region_data[chunk_id].append([])
	#region_data.fill(chunk_template.duplicate(true))
	#print(Region_Data.get_chunk_id(Vector2(10,30),Vector2(010,020),Vector2(10,10)))

#The tile get/set will check if array structure is correct
#to remove the need to populate it at _init
#set just need to make sure the region is populated with nulls
#except the current chunk which should be populated with nulls excpet for the current tile
#get just need to make sure the array sizes are correct
func set_tile(region_coords, tile):
	var chunk_id = get_chunk_id(region_coords)
	var tile_id = get_tile_id(region_coords)
	if region_data.size() == 0:  
		region_data.resize(region_size*region_size)
	if region_data[chunk_id] == null:
		region_data[chunk_id] = []
	if region_data[chunk_id].size() == 0:
		region_data[chunk_id].resize(chunk_size*chunk_size)
	region_data[chunk_id][tile_id] = tile

func get_tile(region_coords):
	var chunk_id = get_chunk_id(region_coords)
	var tile_id = get_tile_id(region_coords)
	if region_data.size() == 0:
		return null
	if region_data[chunk_id].size() == 0:
		return null
	return region_data[chunk_id][tile_id]

