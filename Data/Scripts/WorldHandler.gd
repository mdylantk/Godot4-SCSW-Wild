extends Node2D

@export var tile_size : float = 16 #this is more dependent on the tile map, but the value should be fixed
@export var chunk_size : float = 32


@export var level_data : Level_Data_2D
#TODO: maybe just have one handler for world, and how it load is determin by a resource
#stating static chunks and if it generate void chunks or not
#@export var static_chunks : Dictionary = { 
#	Vector2(0,0):"uid://blyxjt47otoln", 
#	Vector2(4,8):"uid://clicnkneu0ddm",
#	Vector2(7,-2):"uid://bngicde5fixcp",
#	Vector2(-4,5):"uid://cyg3wosoq0787",
#	Vector2(-9,-6):"uid://t7rhh625brgr",
#	Vector2(-3,0):"uid://duqgklvehxux0",
#	Vector2(0,11):"uid://bbaafkh4f04vx",
#	Vector2(0,-21):"uid://t7rhh625brgr",
#	Vector2(42,0):"uid://clicnkneu0ddm"
#	}
var chunk_distance = tile_size*(chunk_size+1)
var offset = Vector2(-2,-2)
var loaded_point = Vector2(0,0)

#preload only work with the direct path, not id
var default_scene = preload("res://Data/Scenes/TilemapTemplate.tscn")
var rare_scene = preload("res://Data/Scenes/RareTemplate.tscn")

var loaded_chunks = {}

func _ready():
	generate_chunks()

func load_chunks(pos):
	var current_origin = loaded_point * chunk_distance
	if (pos.x >= current_origin.x + chunk_distance ||
		pos.x <= current_origin.x - chunk_distance ||
		pos.y >= current_origin.y + chunk_distance ||
		pos.y <= current_origin.y - chunk_distance ) :
			loaded_point = (pos/chunk_distance).round()
			generate_chunks()

#func _process(_delta):
	#pass

func generate_chunks() :
	#var chunk_distance = tile_size*(chunk_size+1)
	var old_chunk_coord = loaded_chunks.keys()
	var x = 0
	var y = 0
	while x <= 3:
		while y <= 3:
			var grid_position = Vector2(x,y) + offset + loaded_point
			if true: #!preloaded_chunks.has(grid_position) : #chunk_distance * (grid_position) != Vector2.ZERO:
				if !loaded_chunks.has(grid_position):
					var map
					if level_data != null:
						var chunk_ref = level_data.get_chunk(grid_position)
						if chunk_ref != null:
							print("loading: " + str(chunk_ref))
							call_deferred("load_chunk",chunk_ref,grid_position,!chunk_ref is String)
					#elif static_chunks.has(grid_position) :
						#var scene_ref = static_chunks[grid_position]
						#call_deferred("load_chunk",scene_ref,grid_position,false)
					elif randi() % 100 <= 4:
						call_deferred("load_chunk",rare_scene,grid_position,true)
					else:
						#map = default_scene.instantiate()
						#load_chunk(default_scene,grid_position,true)
						call_deferred("load_chunk",default_scene,grid_position,true)
						#print("init default scene")
					
				else:
					old_chunk_coord.remove_at(old_chunk_coord.find(grid_position))
			#else:
				#preloaded_chunks[grid_position].visible = true
			y += 1
		y = 0
		x += 1
	for null_pos in old_chunk_coord:
		remove_child(loaded_chunks[null_pos])
		loaded_chunks[null_pos].queue_free()
		#print("removing")
		#print(loaded_chunks[null_pos])
		loaded_chunks.erase(null_pos)

func load_chunk(ref,location = Vector2(), is_loaded = true) :
	var map
	if is_loaded :
		map = ref.instantiate()
	else:
		var loaded_ref = load(ref)
		map = loaded_ref.instantiate()
	map.transform[2] = chunk_distance * location
	add_child(map)
	loaded_chunks[location] = map
	#map.connect("on_chunk_ready", chuck_ready)
	map.on_chunk_ready.connect(chuck_ready)

func get_current_chunk(location):
	var chunk_pos = (location/chunk_distance).round()
	#print(chunk_pos)
	if loaded_chunks.has(chunk_pos):
		return loaded_chunks[chunk_pos]
	#elif preloaded_chunks.has(chunk_pos):
	#	return preloaded_chunks[chunk_pos]
	else:
		return null
		
func chuck_ready(pos):
	get_tree().call_group("Player_Handlers", "chunk_ready", pos, chunk_size * tile_size)
