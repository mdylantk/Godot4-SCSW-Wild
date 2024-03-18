extends TileMap
#this may be self contained. just need configs for the icons
#such as fresh/saltwater icon, specail icon, target and player
#objects will be tiles with data. meaning a fish is a point known
#and it moves base on if there water next to it. moving is being cleared
#and set elsewhere. 

#TODO: probably should use a dictionary for the fish and have the properties there
#and in here have two functions to generate the data for rare and common fish
#it be a bit of a bloat, but will allow randomlized fish if done correctly
#also help compress some logic by requiring only one list

#NOTE: maybe should use fish nodes. a little more costly, but they can move on their
#own or at least can be modified to look diffrent. 
#NOTE: maybe not yet since there wont be as much variation for the prototype

#NOTE: could set this by the one that sets it up to have diffrent icons
#but currently this is just to make fishing more engaging without being too complex
@export var water_atlas_coords : Vector2i
@export var default_fish_atlas_coords : Vector2i
@export var rare_fish_atlas_coords : Vector2i
@export var fish_update_rate : float = 0.1
@export var default_fish_move_rate : float = 0.1
#@export var rare_fish_move_chance : float = 0.3
@export var player_atlas_coords : Vector2i
@export var player_coords : Vector2i
#Note: the cursor may be best off as a gui object so it can be link with progress
#bar
#@export var cursor_atlas_coords : Vector2i
#@export var cursor_coords : Vector2i

@export var test : bool

@onready var cursor = %Cursor
#tilemap should be empty except ground, but could look up tiles if nessary

#active fish could be populated by a function by caller to allow various 
#scenes.
#NOTE: the array is of positions.
#NOTE: wraping around an object or static type would be more useful
#but current the prototype needs to be short and simple 
var running : bool = false
var active_fish : Array[Dictionary]
#var active_fish : Array[Vector2i]
#var active_rare_fish : Array[Vector2i]
#TODO: need something to show charge up. could be a gui


#helper functions. 
#pasue is simply falsing the running and stoping imput(or processes)
#could make a pause bool that have setters that triggers this
func pause():
	running = false

#resume just need to re-enable update(handle lots of the needed check)
#qas well as open up the input and maybe prosses paths that pause may close
func resume():
	fish_update()

func fish_update():
	if running : return #this should only one once
	else: running = !active_fish.is_empty() #but if not running, set to true so the logic starts
	while running:
		if active_fish.is_empty():
			running = false
			print("ending fish update")
			return #breaks the cycle, but running need to be set false first
		for fish_id in range(active_fish.size()):
			var fish = active_fish[fish_id]
			move_fish(fish)
	#TODO: see if there a way to assign timer to a var so checks can be made
	#to prevent more than one of this running
	#NOTE: maybe add a flag and toggle it off when conditions are correct
		await get_tree().create_timer(fish_update_rate).timeout

func move_fish(fish_data:Dictionary):
	if fish_data["move_rate"] >= randf():
		var coords = fish_data["coords"]
		var atlas_coords = fish_data["atlas_coords"]
		var layer = fish_data["layer"]
		var nearby_tiles = get_surrounding_cells(coords)
		nearby_tiles.shuffle()
		while !nearby_tiles.is_empty():
			var picked_coord = nearby_tiles.pop_back()
			var picked_tile = get_cell_atlas_coords(0, picked_coord)
			if picked_tile == water_atlas_coords:
				set_cell(layer,coords,-1)
				set_cell(layer,picked_coord, 0, atlas_coords)
				fish_data["coords"] = picked_coord
				return
				
		
#func move_fish(fish:Vector2i, atlas_coords: Vector2i, move_chance : float = 1):
#	if move_chance >= randf():
#		var nearby_tiles = get_surrounding_cells(fish)
#		nearby_tiles.shuffle()
		#pluck the array untill a vaild tile is found.
		#currently there may no exit/enter conditions. that
		#can be used for the more advance system
#		while !nearby_tiles.is_empty():
			
#			var picked_coord = nearby_tiles.pop_back()
#			var picked_tile = get_cell_atlas_coords(0, picked_coord)
#			if picked_tile == water_atlas_coords:
#				set_cell(1,picked_coord, 0, atlas_coords)
#				set_cell(1,fish,-1)
#				return picked_coord
#	return null

#NOTE: these are placeholder functions. they will work untill the system is redone
#TODO: could merge the create fis data and add fish.
#func add_fish(fish_data:Dictionary):
#func add_fish(coords:Vector2i, atlas_coords:Vector2i = default_fish_atlas_coords,
#	move_rate:float = default_fish_move_rate, type = "fish", layer:int = 1
#	):
func add_fish(coords:Vector2i, atlas_coords:Vector2i = default_fish_atlas_coords,
	layer:int = 1, data:Dictionary = {}
	):
	var fish_data = {
		"coords":coords,
		"atlas_coords":atlas_coords,
		"layer": layer,
		"move_rate": default_fish_move_rate,
		"type": null
	}
	for key in data:
		#will loop the data since it should not be bloated down
		fish_data[key] = data[key]
		
	active_fish.append(fish_data)
	set_cell(fish_data["layer"],fish_data["coords"], 0, fish_data["atlas_coords"])
#func add_fish(coords:Vector2i,atlas_coords:Vector2i, list:Array[Vector2i]):
#	list.append(coords)
#	set_cell(1,coords, 0, atlas_coords)

#func remove_fish(fish_id:int, list:Array[Vector2i]):
#	if list.size() > fish_id:
#		var fish_coords = list[fish_id]
#		list.pop_at(fish_id)
		#NOTE: more than one fish can share a coord
		#so this is improper, but all that means is the 
		#other fish is under the water(hidden) untill it moves
#		set_cell(1,fish_coords,-1)

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if active_fish.is_empty() and test:
		#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		
		add_fish(Vector2i(24,24),rare_fish_atlas_coords,2,
		{"move_rate":randf_range(.5,1),"type":"rare fish"})
		add_fish(Vector2i(24,24))
		add_fish(Vector2i(24,24))
		add_fish(Vector2i(24,24))
		add_fish(Vector2i(24,24))
		add_fish(Vector2i(24,24))

		fish_update()
		await get_tree().create_timer(10).timeout
		pause()
		print("Pause")
		await get_tree().create_timer(5).timeout
		print("Resume")
		resume()
	else:
		#poor way of disabling collsion. need a state switch
		if is_layer_enabled(0):
			set_layer_enabled(0,false)
	
	if running:
		if mouse_state == 2:
			if cursor.value < 80: #cursor.max_value:
			#unable to use float for value so may need to stor value as float
			#and add when >= than 1. also could add a timer
			#then update when at 1
				cursor.value += 1
		elif mouse_state == 1:
			mouse_state = 2
		elif mouse_state == 3:
			mouse_state = 0

var mouse_state: int = 0
#not press(0), just pressed(1), pressed(2), just released(3)
#TODO: may need a time for fill rate instead of using processes
#ALSO should have the cursor bound within a region.this zone is base on a 
#point bottem center(the cat) and the cat can(or will be move) left or right
#up to a certain point.
#on mouse press should triger catch logic which should return data for the fish
#caught(if any) via a signal
func _input(event):
	if running:
	# Mouse in viewport coordinates.
		if event is InputEventMouseButton:
			if event.is_pressed():
				mouse_state = 1
			elif event.is_released():
				mouse_state = 3
				print("catch chance at " + str(cursor.value + 20) + "%")
		
				cursor.value = 0#cursor.min_value
			#print("Mouse Click/Unclick at: ", event.position)
		elif event is InputEventMouseMotion:
			cursor.position = event.position
		#print("Mouse Motion at: ", event.position)




