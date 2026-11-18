#TODO: rename this something to do with generated tilemap
#also maybe should rethink the generator? or make sure it used as data and caculator
#and not expecting a timer (or let owner handler how much an action is called)
class_name One_Bit_Tilemap extends Tilemap_Handler
signal on_chunk_ready(pos)


@export var foilage_generator : Generator_Data = load("uid://c7267jk27323m")#Foilage_Generator.new()

@export var water_generator : Generator_Data = load("uid://pjnqre64113s")
@export var fish_enitity : PackedScene = load("uid://dghoogotf0r7u")
##this is still needed untill there a better way to declare the layer for genertation
##may even pass the tile layers plus some metadata to the generator so it do more of the work
#@export var foilage_layer : TileMapLayer
##assign tile layers to be checked or managed by this node
@export var tile_layers : Array[TileMapLayer]
##since there may be a few tile layers4r
@export var default_tile_size : Vector2i = Vector2i(16,16)
##masks that are applied to certain generators that may need smoothing within this map. 
##Currently it is only a circle mask 
@export var enable_height_masking: bool = true
##reduce the mask size by this values times tile size
@export var height_softmask_reduction_size: float = 2
##reduce the mask size by this values times tile size
@export var height_hardmask_reduction_size: float = 1.5
##apply an offset of the mask position. This is limited to either more control over a small space
##or masking one edge. Note that mask that go pass the tilemap size can breal tile connections.
@export var height_mask_offset: Vector2

@export var fish_spawn_chance: float = 0.1

var processing_step: int = 0

func _ready():
	call_deferred("generate")
		
		
@export var region_size : int = 8
@export var chunk_size : int = 8

##Get an array of tile data at the provide coords. flags is an otinal parameter
##for extentions to filter out which layers get checked. target is the array
##return incase one want to reuse that same array
func get_tiles(coord:Vector2i=Vector2i(), flags:int = 0, target = []) -> Array[TileData]:
	#var data = foilage_layer.get_cell_tile_data(coord)
	#if (data):
	#	target.append(data)
	for tile_layer in tile_layers:
		var data = tile_layer.get_cell_tile_data(coord)
		if (data):
			target.append(data)
	return target

##get the tile sized used by this node. Flags to filter if there more than one 
##managed standard. This is for chunk base generation, but should try to use the
##size of the tile map that is being worked with. The function will allow overriding it to fetch
##that tilemap tile size
func get_tile_size(flag:int=0)->Vector2i:
	return default_tile_size

func generate()->void:
	is_ready = false
	var data : Tile_Info
	var coord : Vector2i
	var global_coord : Vector2i
	var tile_size:Vector2i = get_tile_size()
	#TODO may need to put masks in a global object or resource
	#could allow these to add it if they block generations then remove it when they load in. only issues is chunks that generated before
	#so may be better to have it for static chunks and have random chunks "work with: world generation
	#NOTE:when adding a mask to self, need to make sure it is  center since most tilemaps are top left orgin
	var tile_max_size = max(tile_size.x,tile_size.y)
	var map_size = chunk_size*region_size*tile_max_size
	var map_radius = map_size/2.0
	var masks:Array = []
	var tileData:Array[TileData]
	
	if (enable_height_masking):
		masks.append([
			global_position.x + map_radius + height_mask_offset.x,
			global_position.y + map_radius + height_mask_offset.y,
			map_radius - tile_max_size*height_hardmask_reduction_size, 
			map_radius - tile_max_size*height_softmask_reduction_size
		])
	#resusing data by delaring above the for loop is more efficent, but
	#TODO: the data return should be more static. it is created from a altas coord
	#but really a hole cell_data/tiledata object should be used and then passed
	#then the data is declared at compile instead of runtime, but the Cell_Data
	#may need to be a resource so it can be declare in the editor
	for region_x in range(region_size):
		for region_y in range(region_size):
			if foilage_generator and tile_layers[0]:
				for chunk_x in range(chunk_size):
					for chunk_y in range(chunk_size):
						coord = Vector2i(
							Vector2i(chunk_x,chunk_y)+(Vector2i(region_x,region_y)*chunk_size)
						)
						var tile_data: Tile_Info
						var waterId = -1
						global_coord.x = coord.x*tile_size.x +global_position.x
						global_coord.y = coord.y*tile_size.y +global_position.y
						tileData.clear()
						get_tiles(coord,0,tileData)
						if (tileData.size() == 0):
							
						#if foilage_layer.get_cell_tile_data(coord) == null: 
							if (water_generator):
								tile_data = water_generator.get_tile_info(global_coord,masks)
								if (tile_data):
									waterId  = water_generator.get_connection_id(global_coord,tile_size.x,tile_size.y,masks)
							if (tile_data == null):
								tile_data =  foilage_generator.get_tile_info(global_coord)
							if (tile_data):
								if(waterId >= 0):
									#TODO: probably should let the generator read the tilemap or layer to check for existing tiles
									#so it can merge better with static content
									tile_layers[0].set_cell(coord,tile_data.source_id,water_generator.connection_pos(waterId))
									if (waterId != 14 && waterId != 0 && fish_enitity):
										if (randf() <= fish_spawn_chance):
											var fish = fish_enitity.instantiate()
											fish.global_position = tile_layers[0].map_to_local(coord)
											add_child(fish)
								else:
									tile_layers[0].set_cell(coord,tile_data.source_id,tile_data.atlas_coords)
						#if foilage_layer.get_cell_tile_data(coord) == null: 
						#	data = foilage_generator.get_tile_info(coord)
						#	if data:
						#		foilage_layer.set_cell(coord,data.source_id,data.atlas_coords)
			else:
				return
			await get_tree().process_frame
	is_ready = true
