#@tool
class_name One_Bit_Tilemap extends TileMap
signal on_chunk_ready(pos)

#TODO: make generate logic togglable. also probably add a way to store changes so it can be reset
#else every time the map is loaded, it generates adn changes in editor are saved

#TODO: add a color rex for the bounds ans use noise sharder to color it base on position
#also note that the pos may need to be base off of something, but maybe global be enough

#TODO: catch genarated tiles so static changes can be restored
#or at lest remeber what empty slots was fill in. issue is that ediring genetated tiles may
#cause issues unlesa able to listen to what ever runs when placing tile
#also improve chhunk load to keep more chunk in memory, but hidden to try to reduce
#lag...just need it to update less futher away it is 

#also add resources like chunk and region (or improve them) that handle a lot of the stuff so
#less code is added here or world handler can do most of the logic
#also cell_quadrant_size may or may not work. if could load areas by some other data type(pattern?)
#then could use chunk and regions to store modifed data untill it is unloaded
#and just use a single tile map(down side is material) (some of the lag a mix of init new tile map plus tile updates)
#just need a way to store object (having issue saving tilemap pattern so it may not be best)
#could always store it in a dict, but the set up would be odd
#(one big tilemap may not be good. was having issues wirg 64x64 map, but that may be the tile update though?
#maybe regions should be diffrent tile maps and chunks caculated as needed(any kind of gen)
#so it similar to the current system, but more stuff stays in memory (9 regions of x amount of chunks)
#the question is size. could reduce chunk size to 16 to speed up gen(alnd region can be 32-64 chunks(512+ tiles), but need to load near player first
#also would need to have steps so base gen happen chunk base and advance gen happen delayed
#and only 1-2 regions need to be render at a time
#and a data type will be needed to hold temp chunk data untill it ready to load tiles


@export var bounds : Vector2 = Vector2(32,32) #the bounds which generated content may extends to
@export var bounds_offset : Vector2 #= Vector2(-16,-16)#since most maps are currently built around 0,0 instead of starting from it
#offset is used to correct it. ir remove offset, all maps need to be redesign to start from 0,0, not centered around it

var empty_tiles : Array[Vector2] #if an array is provided, will skip the generation and use the array instead

#@export var generate_foliage_editor : bool = false #it be better to clear or regen the loaded chunks
@export var allow_foliage_generation : bool = true

@export var detail_map: FastNoiseLite
@export var variation_map : FastNoiseLite
@export var random_noise : FastNoiseLite
@export_file("*.tscn") var background = "uid://wqfpqmmkbg0n"

#tile_size should be a const someplace or maybe the timeset can get a min size
var tile_size : float = 16
@onready var region_test = Region_Data.new()

var is_ready : bool = false: #a flag to state if the tilemap ready to be used or still running eneration logic
	#could use a signal here
	set (value):
		if is_ready != value:
			is_ready = value
			if is_ready:
				#NOTE: seems there a process spike when ready. maybe visabilty
				#truth is the level_data is in rewrite so maybe something there
				#also need to check random tile to make sure it not slow
				#as well as see if tile data a possible issue
				#visible = true
				on_chunk_ready.emit(global_position)
				#may need to include tile size. then world times that by map size
				#but these values should be a const someplace since change them in certain cases(like world) would bread the grid
			else:
				#visible = false
				pass
	get:
		return is_ready
		
func delayed_visiblity():
	visible = true

#this is a test system. thi data should be held in a resource so diffrent generation can be used
#@export var ground_tiles : Array[Vector2] #current no tile will be used. 
@export var grass_tiles : Array[Vector2i] = [
	Vector2i(5,0),
	Vector2i(6,0),
	Vector2i(7,0),
	Vector2i(0,2),
	#Vector2i(2,2), #a bit odd of a tile. look like a tree like vine more than grass
	#Vector2i(1,2)
	#adding empty to allow more emprty space
	Vector2i(0,0)
]
@export var tree_tiles : Array[Vector2i] = [
	Vector2i(0,1),
	Vector2i(1,1),
	Vector2i(2,1),
	Vector2i(3,1),
	Vector2i(4,1),
	Vector2i(5,1),
	Vector2i(3,2),
	Vector2i(4,2),
	Vector2i(6,2),
	Vector2i(0,0)
]
@export var rock_tiles : Array[Vector2i] = [
	Vector2i(5,2),
	Vector2i(1,0),
	Vector2i(2,0),
	Vector2i(3,0),
	Vector2i(4,0),
	Vector2i(0,0)
]

var chunk_size = 33
var tile_id = 0
var chunk_id = 0
var height_value := func(position:Vector2): return 0
func new_gen():
	#print_debug("map size" + str(Region_Data.chunk_size * Region_Data.region_size))
	var water_cells = []
	while !is_ready:
		#print(str(chunk_id) + "<=" + str(Region_Data.chunk_size * Region_Data.chunk_size))
		if chunk_id < Region_Data.region_size * Region_Data.region_size:
			region_test.call_on_all_tiles_in_chunk(
				func(region_coords):
					if get_cell_tile_data(0,region_coords) == null:
						var tile_location : Vector2 = (region_coords as Vector2) + bounds_offset
						var random_tile = pick_foliage_tile(tile_location +global_position)
						if random_tile != Vector2i.ZERO:
							if random_tile == Vector2i(8,5):
								water_cells.append(region_coords)
							else:
								set_cell(0,region_coords,0,random_tile)
			,chunk_id)
			chunk_id += 1
			await get_tree().create_timer(.1).timeout
		else:
			is_ready = true
			set_cells_terrain_connect(0,water_cells,1,0)
			check_water_tiles(water_cells)
			water_cells = []
			return
			
func check_water_tiles(cells):
	if get_layers_count() < 2:
		add_layer(1)
	var water_boarder_tiles = [Vector2i(1,1),Vector2i(2,0),Vector2i(3,1),Vector2i(2,2)]
	for tile in cells:
		if get_cell_atlas_coords(0,tile) != Vector2i(2,1) or get_cell_source_id(0,tile) != 1:
			continue
		var boarder_tile = get_surrounding_cells(tile)
		for other_tile in boarder_tile:
			if get_cell_source_id(0,other_tile) == 1:
				if water_boarder_tiles.has(get_cell_atlas_coords(0,other_tile)):
					if variation_map.get_noise_2d(tile.x*16, tile.y*16) > 0.25:
						set_cell(1,tile,0,Vector2i(5,2))
						
			
#func old():
#	if true:
#		for i in range(Region_Data.chunk_size*Region_Data.chunk_size):
#	for tile_id in range(chunk_size):
#		#TODO: should verify if id are in range, but not too importaint
#			if tile_id == chunk_size*chunk_size:
#				is_ready = true
#				#tile_id += 1
#				return
#			var coords=get_coords(tile_id)
#			if get_cell_tile_data(0,coords) == null:
#				var tile_location : Vector2 = (coords as Vector2) + bounds_offset
#				var random_tile = pick_foliage_tile(tile_location*16 +global_position)
#				if random_tile != Vector2i.ZERO:
#					set_cell(0,coords,0,random_tile)
#					
#			tile_id += 1
#		await get_tree().create_timer(1).timeout
	#visible = true
	#on_chunk_ready.emit(global_position)
	#set_process(false)
	
	#todo: timer base loop untill all chunks are generated
	pass
func get_coords(tile_id:int = 0):
	var tile_location:Vector2i = Vector2i(
		tile_id%int(chunk_size),
		floor(tile_id/chunk_size)
		)
	#print_debug(str(tile_id)+"of "+str(chunk_size))
	return tile_location

		
func _ready():
	if !y_sort_enabled:
		y_sort_enabled = true #note this override it,but currently y sort is wanted and new tilemaps is not including it
	
	if random_noise == null:
		#this is for minor population of objects. 
		#a global/world set of noise would be used for making regions
		random_noise = FastNoiseLite.new()
		
	if (background != null):
		var loaded_ref = load(background)
		var loaded_backround = loaded_ref.instantiate()
		add_child(loaded_backround)
		#loaded_backround.size = bounds*(16.5)
		loaded_backround.size = Vector2(chunk_size,chunk_size)*tile_size
	
	#visible = false
	new_gen()
	return

func recaculate_empty_tiles(enable_generation: bool = true):
	empty_tiles.clear()
	var children_positions = {}
	for child in get_children():
		children_positions[(child.global_position/(16)).floor()] = child
		
	if empty_tiles.is_empty() && allow_foliage_generation:
		visible = false
		var x = 0
		var y = 0
		#generate_chunk(position)
		while x <= bounds.x:
			while y <= bounds.y:
				var tile_location = Vector2(x,y)  + bounds_offset #bound is needed for the null check
				#print(tile_location)
				if !children_positions.has(tile_location):
					if get_cell_tile_data(0,tile_location) == null : #&& get_cell_tile_data(1,tile_location) == null && get_cell_tile_data(2,tile_location) == null :
						empty_tiles.append(Vector2(x,y)) #incase static array is used...best to have a rar grid not base on offset, then add it
					#note: if static array is provided, objects on the map may be overrided
					#static map a last case solution and if it is used, could move this logic up
				y += 1
			y = 0
			x += 1
		set_process(enable_generation) #incase it is off. also could use a timer and an await, but this works for now


func pick_foliage_tile(pos):
	var noise_value = round((random_noise.get_noise_2d(pos.x,pos.y)+1)*5)
	var water_value = round(random_noise.get_noise_2d(pos.x,pos.y))
	var variation_roll = randf()
	var random_roll = randi() % 100
	if detail_map != null and variation_map != null:
		random_roll = (detail_map.get_noise_2d(pos.x*5,pos.y*5)+1)*50
		variation_roll = (variation_map.get_noise_2d(pos.x*5,pos.y*5)+1)/2
	
	if water_value < 0:
		return Vector2i(8,5)
	elif grass_tiles.size() > 0 && random_roll >= 50: #60:
		return grass_tiles[round((grass_tiles.size()-1)*variation_roll)]
		#return grass_tiles[randi() % grass_tiles.size()*variation_roll]
		
	elif rock_tiles.size() > 0 && random_roll < 10:
		return rock_tiles[round((rock_tiles.size()-1)*variation_roll)]
		#return rock_tiles[randi() % rock_tiles.size()]
		
	elif tree_tiles.size() > 0 && random_roll < 45:
		return tree_tiles[round((tree_tiles.size()-1)*variation_roll)]
		#return tree_tiles[randi() % tree_tiles.size()]
		
	else:
		return Vector2i(0, 0)
		

