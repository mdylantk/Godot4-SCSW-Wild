class_name Fishing_Pond_Map extends TileMap
signal catched(fish_data:Dictionary)
signal missed(vaild:bool) #return true if catch was in water, else false
signal canceled()


@export var water_atlas_coords : Vector2i
@export var default_fish_atlas_coords : Vector2i
@export var rare_fish_atlas_coords : Vector2i
@export var fish_update_rate : float = 0.1
@export var default_fish_move_rate : float = 0.1
#TODO: should there be a min and max fish rate by default?
#@export var rare_fish_move_chance : float = 0.3
@export var player_atlas_coords : Vector2i
@export var player_coords : Vector2i

@export var fishing_distance : float = 6

@onready var cursor = %Cursor

var running : bool = false :
	set(value):
		running = value
		if running:
			Game.allow_input(false)
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			set_layer_enabled(0,true)
			visible = true
		else:#if active_fish.is_empty():
			Game.allow_input(true)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			set_layer_enabled(0,false)
			visible = false
var active_fish : Array[Dictionary]


#NOTE: mouse_state = -1 is to prevent input untill a fresh press

func pause():
	running = false

func resume():
	fish_update()
	mouse_state = -1
	#below is a failsafe incase input breaks
	#though the logic to handle it may be faulty if input bugs out
	

#NOTE: Start() may be redundent? but also easier to understand
#TODO: look to see how to make start and resume to be diffrent
#func start():
#	fish_update()
	
func end():
	clear_fish()
	mouse_state = -1

func cancel():
	canceled.emit()
	end()

func get_water_coords() -> Array[Vector2i]:
	return get_used_cells_by_id(0, -1, water_atlas_coords)

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
				
		
#NOTE: could use a resource, but dictionary quicker for the protype
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

func clear_fish():
	for fish in active_fish:
		var coords = fish["coords"]
		var layer = fish["layer"]
		set_cell(layer,coords,-1)
	active_fish.clear()
	running = false

func _process(delta):
	
	if active_fish.is_empty():
		pause()

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
			
func catch_fish(coords:Vector2i):

	var vaild_coords :Array[Vector2i] = [Vector2i(1,0),Vector2i(1,1), Vector2i(0,1), Vector2i(-1,1),
		Vector2i(-1,0),Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1)
	]
	var caught_fish_layer:int = -1
	var caught_fish_coords:Vector2i = Vector2i(-1,-1)
	vaild_coords.shuffle()
	vaild_coords.push_front(Vector2i(0,0))
	#print(vaild_coords)
	for index in range(vaild_coords.size()):
		#print(index)
		var picked_coords = coords + vaild_coords[index]
		var picked_tile = get_cell_atlas_coords(0, picked_coords)
		if picked_tile == water_atlas_coords:
			for layer in get_layers_count():
				if layer > 0:
					var fish = get_cell_atlas_coords(layer, picked_coords)
				#TODO: could look for fish and check it. then if fish cought
				#loop the active fish untill vaild fish is found
					if fish != Vector2i(-1,-1):
						var catch_chance : float = (cursor.value + 20) - (10*index)
						var roll = randf_range(0,100)
						if catch_chance <= 0:
							missed.emit(true)
							return
						elif roll <= catch_chance:
							caught_fish_coords = picked_coords
							caught_fish_layer = layer
							for picked_fish in active_fish:
								if (picked_fish["coords"] == caught_fish_coords and
									picked_fish["layer"] == caught_fish_layer
								):
									picked_fish["catch_roll"] = roll
									picked_fish["catch_chance"] = catch_chance
									catched.emit(picked_fish)
									return
		elif vaild_coords[index] == Vector2i(0,0):
			print_debug("was not in water")
			missed.emit(false)
			return
	missed.emit(true)
var mouse_state: int = 0

func _input(event:InputEvent):
	if running:
		if event.is_action("Cancel"):
			cancel()
		elif event.is_action("Accept"):# is InputEventMouseButton:
			#TODO: need to have release reset input on new/resume game
			#but also need to make sure release is not needed to use input
			#also rename mouse_state to input or catch_state 
			if event.is_pressed() and mouse_state == 0:
				mouse_state = 1
			elif event.is_released() and mouse_state == 2:
				mouse_state = 3
				catch_fish(local_to_map(cursor.position))
				cursor.value = 0#cursor.min_value
			elif event.is_released() and mouse_state < 0:
				mouse_state = 0
		elif event is InputEventMouseMotion:
			var cursor_coord: Vector2 = event.position
			var local_player_coords = map_to_local(player_coords)
			var vector_from_player: Vector2 = cursor_coord - local_player_coords
			var max_length = fishing_distance*16
			
			if vector_from_player.length() > max_length:
				cursor_coord = local_player_coords + (vector_from_player.normalized()*max_length)
			cursor.position = cursor_coord
