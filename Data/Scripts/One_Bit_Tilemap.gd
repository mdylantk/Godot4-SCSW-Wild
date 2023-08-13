class_name One_Bit_Tilemap extends TileMap

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

#note if so, it possible the array could go out side of bounds
#so there may need checks...also offset
#COULD use a tooling system probably to prebake the array

#note, if add multiplayer, should catched the changes to send to other players instead of trying to get the same gen
#unless seed base generation becomes the same generation (current not)

#NOTE: need to wait when spawning or teleporting for the chunk to generate
#a loading screen or hiding the map untill generated may help
#JUST need to have the init spawn(and teleports) frezze logic (and hide screen for a bit) untill it is loaded
#also have a spot on the map that can be spawn on (or force remove object at spawn point if not importaint)


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
				if get_cell_tile_data(0,tile_location) == null : #&& get_cell_tile_data(1,tile_location) == null && get_cell_tile_data(2,tile_location) == null :
					empty_tiles.append(Vector2(x,y)) #incase static array is used...best to have a rar grid not base on offset, then add it
					#note: if static array is provided, objects on the map may be overrided
					#static map a last case solution and if it is used, could move this logic up
				y += 1
			y = 0
			x += 1
		set_process(true) #incase it is off. also could use a timer and an await, but this works for now
func pick_foliage_tile():
	
	#note: should roll a few numbers and store to decide major aspects of the generation
	#this would be rolled once on ready
	#and smaller roll for fine details which would happen here
	#an array,dict, or resource would be used to full types out of.
	#grasses would be an array of vector2 that a random roll could pic the index.
	#will help with some of the assests so spread appart. 
	#with a resource, could design a bioem. also could double up on altas coords  to make some tiles more common
	#or do an exp and round system so ones farther way would be less common
	#or have serval arrays that use a weight system 
	#many ways. there also could use noise and try to genrate bloches so things may feel group together instead of fully random
	
	#this is a bit easier to understand. the first roll is stored
	#so lower on the list are just as possible as higher up since the number is not rerolled
	#then it pulls from an array instead from a line. allow more typews to be group without
	#editing the assets
	#also the staric ranges should be converted to dynamic so that the ratio can be randomized
	#like adding the roll and using it as a base for the next check. the random ranges
	#for these bounds should also dynamily adjust to prevent overbounding...or just clamp the values
	# maybe having 10 offset for each, so the 60 is split beween each(like 1-20 each) or something
	#or have a weight system, and max roll for random roll is the total wieght
	#that be better, but the eypes may need to be stored in an array.
	#also may need to be dict of arrays of int and vector2i to support additinal tilesets
	#the resource that should be made to hold this data should have getters so
	#it decide the logic, not the tilemap
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
	
	
	#randi() % 8 #0-7
	#note: could have an array for each type. grass, tree, cover, rocky and others
	#could even have a float or int as an id(like generic weight) maybe add up the weight and rand with that pluss null offset
	#the tree path nice too, just messy. forest-> grass, tree, plain-> grasses, paths, trees
	#there noise that could be used too, but a bit compucated. could draw masks out on the tile map as well, but the theme somewhat compucate that
	#if randi() % 10 >= 4:
	#	if randi() % 10 >= 4:
	#		return Vector2i(5 + randi() % 3, 0)
	#	elif randi() % 10 > 6:
	#		return Vector2i(3 + randi() % 3, 1)
	#	else:
	#		return Vector2i(randi() % 6, 1)
	#elif randi() % 10 > 4:
	#	return Vector2i(1 + randi() % 4, 0)
		#5 + randi() % 3 #5 + 0-3 = 5-7
	#if RandomNumberGenerator
	#a temp way to pick random tiles
	#return Vector2i(0, 0)
