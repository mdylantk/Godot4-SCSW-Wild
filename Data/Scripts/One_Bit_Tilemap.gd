class_name One_Bit_Tilemap extends TileMap
signal on_chunk_ready(pos)

@export var bounds : Vector2 = Vector2(32,32) #the bounds which generated content may extends to
@export var bounds_offset : Vector2 #= Vector2(-16,-16)#since most maps are currently built around 0,0 instead of starting from it
#offset is used to correct it. ir remove offset, all maps need to be redesign to start from 0,0, not centered around it

@export var empty_tiles : Array[Vector2] #if an array is provided, will skip the generation and use the array instead

var is_ready : bool = false: #a flag to state if the tilemap ready to be used or still running eneration logic
	#could use a signal here
	set (value):
		if is_ready != value:
			is_ready = value
			if is_ready:
				visible = true
				on_chunk_ready.emit(global_position)
				#may need to include tile size. then world times that by map size
				#but these values should be a const someplace since change them in certain cases(like world) would bread the grid
			else:
				visible = false
	get:
		return is_ready

#this is a test system. thi data should be held in a resource so diffrent generation can be used
#@export var ground_tiles : Array[Vector2] #current no tile will be used. 
@export var grass_tiles : Array[Vector2i] = [
	Vector2i(5,0),
	Vector2i(6,0),
	Vector2i(7,0),
	Vector2i(0,2),
	#Vector2i(2,2), #a bit odd of a tile. look like a tree like vine more than grass
	#Vector2i(1,2)
	
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
	Vector2i(6,2)
]
@export var rock_tiles : Array[Vector2i] = [
	Vector2i(5,2),
	Vector2i(1,0),
	Vector2i(2,0),
	Vector2i(3,0),
	Vector2i(4,0)
]

func _process(_delta):
	var count = 16
	while count > 0:
		if empty_tiles.is_empty():
			set_process(false) #turn it off, but may need to be removed if other logic is added here
			#visible = true
			count = 0
			is_ready = true
			break
		else:
			var random_tile = pick_foliage_tile()
			var tile_location = empty_tiles.pop_back() + bounds_offset
			if random_tile != Vector2i.ZERO:
				set_cell(0,tile_location,0,random_tile)
		count -= 1
		
func _ready():
	var children_positions = {}
	for child in get_children():
		children_positions[(child.global_position/(16)).floor()] = child
	#print(children_positions)
	#print("chunk loaded:" + str(self))
	#randomize()
	if !y_sort_enabled:
		y_sort_enabled = true #note this override it,but currently y sort is wanted and new tilemaps is not including it
	#if !layer[0].y_sort_enabled:
	#	layer[0].y_sort_enabled = true
	if empty_tiles.is_empty():
		visible = false
		var x = 0
		var y = 0
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
		set_process(true) #incase it is off. also could use a timer and an await, but this works for now
func pick_foliage_tile():
	
	var random_roll = randi() % 100
	if random_roll <= 30:
		#grass_tiles
		return grass_tiles[randi() % grass_tiles.size()]
	elif random_roll <= 60:
		#tree_tiles
		return tree_tiles[randi() % tree_tiles.size()]
	elif random_roll <= 70:
		#rock_tiles
		return rock_tiles[randi() % rock_tiles.size()]
	else:
		return Vector2i(0, 0)
