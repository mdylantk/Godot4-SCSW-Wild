#@tool
class_name One_Bit_Tilemap extends TileMap
signal on_chunk_ready(pos)

@export var foilage_generator : Generator_Data = load("uid://c7267jk27323m")#Foilage_Generator.new()

func _ready():
	set_meta("is_ready", false)
	if !y_sort_enabled:
		y_sort_enabled = true #note this override it,but currently y sort is wanted and new tilemaps is not including it

	if foilage_generator != null:
		foilage_generator.generate(self)
		foilage_generator.scene_finished.connect(on_scene_finished)

func on_scene_finished(generator : Generator_Data, scene:Node):
	if scene == self:
		set_meta("is_ready", true)
		#there is no need to listen once finished
		foilage_generator.scene_finished.disconnect(on_scene_finished)
