@tool
class_name Level_Data_2D extends Resource
#contains ref to tilemaps, how to handle null ref, and level related data

#this should be what generate if there is no static chunk
#note, not sure if packed scenr need to be loaded 
#@export var default_chunk : PackedScene #= preload("res://Data/Scenes/TilemapTemplate.tscn")
@export_file("*.tscn") var default_chunk : String = "res://Data/Scenes/Maps/TilemapTemplate.tscn"
#@export var null_chunk : PackedScene
@export_file("*.tscn") var null_chunk : String = "res://Data/Scenes/Maps/NullZone.tscn"
@export var return_null_on_default: bool = false 


#may use this instead of return_null_on_default
#will generate default or random tiles up to bounds unless ignored. 
@export var level_max_bounds: Vector2
@export var level_min_bounds: Vector2
@export var use_level_bounds: bool = false
#note: a way to handle random chunks are still needed. currently usong array[0] inless 10% chance
#is rolled...then a random array between 0-max is picked


#should be ref by id and loaded in via regions else if small then just need an object to get the data from
#@export var old_static_chunks : Dictionary = { 
	#Vector2(0,0):"uid://blyxjt47otoln", 
	#Vector2(4,8):"uid://clicnkneu0ddm",
	#Vector2(7,-2):"uid://bngicde5fixcp",
	#Vector2(-4,5):"uid://cyg3wosoq0787",
	#Vector2(-9,-6):"uid://t7rhh625brgr",
	#Vector2(-3,0):"uid://duqgklvehxux0",
	#Vector2(0,11):"uid://bbaafkh4f04vx",
	#Vector2(0,-21):"uid://t7rhh625brgr",
	#Vector2(42,0):"uid://clicnkneu0ddm"
	#}
	
@export var chunks : Array[Chunk_Data] :
	set(value):
		chunks = value
		sort_chunks()
	get:
		return chunks

#TODO add a region size/bound option to allow generation upto a certain size

var static_chunks = {}
var random_chunks = []

#NOTE: should just have chunks and this will sort it into static and random dict
#the default can be empty or filled out, but a flag may be needed to overrided return hull on default
func sort_chunks():
	if static_chunks.is_empty() && chunks.size() > 0:
		for chunk_data in chunks:
			var chunk_scene = chunk_data.chunk_scene_path
			if ResourceLoader.exists(chunk_scene, "PackedScene"):
				if chunk_data.is_static_chunk:
					static_chunks[chunk_data.static_location] = chunk_scene
				else:
					random_chunks.append(chunk_scene)
			else:
				print_debug(str(chunk_scene) + " is not vaild scene")

func get_chunk(grid_location = Vector2()):
	if grid_location in static_chunks:
		#print_debug("new static chunk is being called")
		return static_chunks[grid_location]
	else:
		if use_level_bounds:
			#issue: grid_loaction not as bounding box. need to offset it to be positive
			if (grid_location.x <= level_max_bounds.x && grid_location.y <= level_max_bounds.y &&
				grid_location.x >= level_min_bounds.x && grid_location.y >= level_min_bounds.y):
				if randi() % 100 > 90 && random_chunks.size() > 0:
					#print_debug("rare chunk")
					return random_chunks[randi() % random_chunks.size()]
				else:
					return default_chunk 
			else:
				#print_debug("null chunk")
				return null_chunk
		if default_chunk != null || !return_null_on_default:
			if randi() % 100 > 90 && random_chunks.size() > 0:
				#print_debug("rare chunk")
				return random_chunks[randi() % random_chunks.size()]
			else:
				return default_chunk
	#print_debug("null chunk")
	return null_chunk
