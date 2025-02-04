#TODO: rename this something to do with generated tilemap
#also maybe should rethink the generator? or make sure it used as data and caculator
#and not expecting a timer (or let owner handler how much an action is called)
class_name One_Bit_Tilemap extends Tilemap_Handler
signal on_chunk_ready(pos)


#TODO: do not depend on this much. use a node for foliage generation or use level_data
#to do the generation. since the static levels are a scene, this may be best
#OR make an extended tilemap that format the layers base on global config? so adding and 
#removing wont be a problem.

@export var foilage_generator : Generator_Data = load("uid://c7267jk27323m")#Foilage_Generator.new()

@export var foilage_layer : TileMapLayer


func _ready():
	
	#set_meta("is_ready", false)
	#if !y_sort_enabled:
	#	y_sort_enabled = true #note this override it,but currently y sort is wanted and new tilemaps is not including it

	if foilage_generator != null and foilage_layer != null:
		foilage_generator.generate(foilage_layer)
		foilage_generator.scene_finished.connect(on_scene_finished)
	else:
		is_ready = true

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
