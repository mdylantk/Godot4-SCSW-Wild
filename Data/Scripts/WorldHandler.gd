extends Node2D

#note: @tool is risky and may spam error so if ever adding it, need to gate the logic

###TODO: either save and unload or hide and disable collsions so that other instances can be loaded in
#another option is to laod another instance and idle the current one, but for now that a bit complex
#also need a way to know where a player spawn, but then again global position is fine...just need to
#make sure there no colsion at that point. may need to store player global as world position
#if instnace have another exit, it could offset this. note that a static chunk (or empty chuck)
#would need to exist at the exit chuck or an improper chunk may spawn (player spawning in the middel
#of a lake for an example)

#NOTE: may need to have actor/player acess this and this handle letting them know which chunk is loaded
#unloaded chunks would caouse actors to freeze or act if there no land(a colsion boarder mat be better
#or better yet, add a c-box on the zone untill it is loaded (unlesses it need to check for collsion onn generation))
#the main point is for actords to get a ref to the timemap they are standing on.
#and get acess to display info and status of the chunk
#the main point is having a function that can take a location and convert it to chink space correctly
#probably part of the get chink function so less fnction are needed to be known about

#need to load in 9 scenes. idealy a func to run future checks (so certain types may spawn or fix areas will spawn)
#currently 0,0 may be ignored for the staring tile



#need to know the player location or players. these will be loading nodes
#so a for loop to check each node location and see what map to load
@export var tile_size : float = 16 #this is more dependent on the tile map, but the value should be fixed
@export var chunk_size : float = 32
#NOTE: may add the chunks in editor?
#and only store dynmicly generated and loacted chunks
#but any loaded chunks need to be hidden or even unloaded if it hurts performance
#or keep this and try to have @tool load it in
@export var static_chunks : Dictionary = { #Maybe have this elsewhere or generated with a tool componet
	Vector2(0,0):"uid://blyxjt47otoln", 
	Vector2(4,8):"uid://clicnkneu0ddm",
	Vector2(7,-2):"uid://bngicde5fixcp",
	Vector2(-4,5):"uid://cyg3wosoq0787",
	Vector2(-9,-6):"uid://t7rhh625brgr",
	Vector2(-3,0):"uid://duqgklvehxux0",
	Vector2(0,11):"uid://bbaafkh4f04vx",
	Vector2(0,-21):"uid://t7rhh625brgr",
	Vector2(42,0):"uid://clicnkneu0ddm"
	}  #need to load ref before using it. load() casue an endless loop if used in the function
#test to see if it will work with inst scenes
var chunk_distance = tile_size*(chunk_size+1)
var offset = Vector2(-2,-2)
var loaded_point = Vector2(0,0)
#note, unable to use uid for preload
var default_scene = preload("res://Data/Scenes/TilemapTemplate.tscn") #NOTE: this may change if file moves
var rare_scene = preload("res://Data/Scenes/RareTemplate.tscn")

#var preloaded_chunks = {} #tilemaps placed in the editor
#NOTE: Above may be remove since it may add more nodes and best to load/unload it
#may need a world map scene as a tool to map their position. 
#or
var loaded_chunks = {}

#var loaders = [] #since it is an array, adding/removing should not happen often
#need a setter function. alse should auto remove null. could also just use the player pawn


func _ready():
	#for child in get_children(): 
	#	if child is TileMap:
	#		var child_chunk_location = (child.position/chunk_distance).round()
	#		if child_chunk_location * chunk_distance != child.position:
	#			child.position= child_chunk_location * chunk_distance
			#also might need to force adjust anything offgrid...as a failsafe
	#		preloaded_chunks[child_chunk_location] = child #placeholder. need the chunk grid location
	#loop children and map tilemaps?
	#print("world_handler loaded")
	#call_deferred("generate_chunks")
	#may not need to call deferred since the chunks generate after
	#also should use frig location in name, not scaling id. could lead to large names in long playthroughts
	generate_chunks()

func _process(_delta):
	
	var player_ref = Global.get_player_handler().pawn
	#if (Global.local_player != null):
	#	player_ref = Global.local_player
	#need to use the payer ref in Player handlers
	#maybe have a system that store loader ref in an array. likr regestering them as one instead of just grabing it
	#if was c++ the type be nod2d or a child of it that have position
	
	if player_ref != null:
		#todo: probably should  have this as a callable that either the player or game handler calls
		#could reduce logic in this tick and reduce the need to know the player ref
		var current_origin = loaded_point * chunk_distance
		#Note: also could have the wait for chunk to load link here, but that only useful for spawn/teleport
		if (player_ref.get_position().x >= current_origin.x + chunk_distance ||
			player_ref.get_position().x <= current_origin.x - chunk_distance ||
			player_ref.get_position().y >= current_origin.y + chunk_distance ||
			player_ref.get_position().y <= current_origin.y - chunk_distance ) :
				
			loaded_point = (player_ref.get_position()/chunk_distance).round()
			
			generate_chunks()
			
			#print("player current need new chucks loaded")
			#print(current_origin)
			pass
	#need to check player poss with active point. will focus on single player for now
	#offset may be key. it where it spawns, but 0,0 is the origin. if player pass the size in an axie, run a loop of children, and unload them
	#may store them in an array or dict

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
					if static_chunks.has(grid_position) :
						var scene_ref = static_chunks[grid_position]
						#map = scene_ref.instantiate()
						#pretty much look up a cord in a dict and then use the value(a scene path) to spawn it in
						#print("init a diffrent scene")
						#if map == null:
						#	map = default_scene.instantiate()
						#	print("if init fail, init default")
						#load_chunk(scene_ref,grid_position,true)
						call_deferred("load_chunk",scene_ref,grid_position,false)
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
	map.connect("on_chunk_ready", chuck_ready)

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
