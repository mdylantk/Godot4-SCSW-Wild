#TODO: rename this something to do with generated tilemap
#also maybe should rethink the generator? or make sure it used as data and caculator
#and not expecting a timer (or let owner handler how much an action is called)
class_name One_Bit_Tilemap extends Tilemap_Handler
signal on_chunk_ready(pos)


@export var foilage_generator : Generator_Data = load("uid://c7267jk27323m")#Foilage_Generator.new()

@export var water_generator : Generator_Data = load("uid://pjnqre64113s")
@export var fish_enitity : PackedScene = load("uid://dghoogotf0r7u")

@export var foilage_layer : TileMapLayer

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
	#set_meta("is_ready", false)
	#if !y_sort_enabled:
	#	y_sort_enabled = true #note this override it,but currently y sort is wanted and new tilemaps is not including it

	#if foilage_generator != null and foilage_layer != null:
	#	foilage_generator.generate(foilage_layer)
	#	foilage_generator.scene_finished.connect(on_scene_finished)
	#else:
	#	is_ready = true
	pass

#TODO: either have this or tilemap handler have a secondary ready event
#that is called when all the generators and setup code is ran kind of like before
#but since tilemap handler will be known to the world generator, the signal can be listen too
func on_scene_finished(generator : Generator_Data, scene:Node):
	if scene == foilage_layer:
		set_meta("is_ready",true)
		is_ready = true
		#set_meta("is_ready", true)
		#there is no need to listen once finished
		foilage_generator.scene_finished.disconnect(on_scene_finished)
		
		
@export var region_size : int = 8
@export var chunk_size : int = 8
func generate()->void:
	is_ready = false
	var data : Tile_Info
	var coord : Vector2i
	var global_coord : Vector2i
	#TODO may need to put masks in a global object or resource
	#could allow these to add it if they block generations then remove it when they load in. only issues is chunks that generated before
	#so may be better to have it for static chunks and have random chunks "work with: world generation
	#NOTE:when adding a mask to self, need to make sure it is  center since most tilemaps are top left orgin
	var tile_max_size = max(foilage_layer.tile_set.tile_size.x,foilage_layer.tile_set.tile_size.y)
	var map_size = chunk_size*region_size*tile_max_size
	var map_radius = map_size/2.0
	var masks:Array = []
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
			if foilage_generator and foilage_layer:
				for chunk_x in range(chunk_size):
					for chunk_y in range(chunk_size):
						coord = Vector2i(
							Vector2i(chunk_x,chunk_y)+(Vector2i(region_x,region_y)*chunk_size)
						)
						var tile_data: Tile_Info
						var waterId = -1
						global_coord.x = coord.x*foilage_layer.tile_set.tile_size.x +global_position.x
						global_coord.y = coord.y*foilage_layer.tile_set.tile_size.y +global_position.y
						if foilage_layer.get_cell_tile_data(coord) == null: 
							if (water_generator):
								tile_data = water_generator.get_tile_info(global_coord,masks)
								if (tile_data):
									waterId  = water_generator.get_connection_id(global_coord,foilage_layer.tile_set.tile_size.x,foilage_layer.tile_set.tile_size.y,masks)
							if (tile_data == null):
								tile_data =  foilage_generator.get_tile_info(global_coord)
							if (tile_data):
								if(waterId >= 0):
									#TODO: probably should let the generator read the tilemap or layer to check for existing tiles
									#so it can merge better with static content
									foilage_layer.set_cell(coord,tile_data.source_id,water_generator.connection_pos(waterId))
									if (waterId != 14 && waterId != 0 && fish_enitity):
										if (randf() <= fish_spawn_chance):
											var fish = fish_enitity.instantiate()
											fish.global_position = foilage_layer.map_to_local(coord)
											add_child(fish)
								else:
									foilage_layer.set_cell(coord,tile_data.source_id,tile_data.atlas_coords)
						#if foilage_layer.get_cell_tile_data(coord) == null: 
						#	data = foilage_generator.get_tile_info(coord)
						#	if data:
						#		foilage_layer.set_cell(coord,data.source_id,data.atlas_coords)
			else:
				return
			await get_tree().process_frame
	is_ready = true
