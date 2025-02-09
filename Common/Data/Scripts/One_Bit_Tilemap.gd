#TODO: rename this something to do with generated tilemap
#also maybe should rethink the generator? or make sure it used as data and caculator
#and not expecting a timer (or let owner handler how much an action is called)
class_name One_Bit_Tilemap extends Tilemap_Handler
signal on_chunk_ready(pos)


@export var foilage_generator : Generator_Data = load("uid://c7267jk27323m")#Foilage_Generator.new()

@export var foilage_layer : TileMapLayer

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
						if foilage_layer.get_cell_tile_data(coord) == null: 
							data = foilage_generator.get_tile_info(coord)
							if data:
								foilage_layer.set_cell(coord,data.source_id,data.atlas_coords)
			else:
				return
			await get_tree().process_frame
	is_ready = true
