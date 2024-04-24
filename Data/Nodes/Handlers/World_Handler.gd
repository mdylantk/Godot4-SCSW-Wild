class_name World_Handler extends Node2D

#TODO: add common world event as signals and call them correct so they can be listen to
#updates that state it pos/souce and if it load/unloaded
#signal chunk_update(tile_map, chunk_position, is_unloaded)
#signal region_update

@export var tile_size : float = 16 #this is more dependent on the tile map, but the value should be fixed
@export var world_seed : int = 0

@export var level_data : Level_Data :
	set(value):
		print_debug("setting level")
		if level_data != value:
			#load new level
			if value != null:
				value.level_created.connect(on_level_created)
				value.level_removed.connect(on_level_removed)
				value.load_level()
				
			if level_data != null:
				#unload old level
				level_data.unload_level()
				level_data.level_created.disconnect(on_level_created)
				level_data.level_removed.disconnect(on_level_removed)
			level_data = value

	
func on_level_created(level:Node):
	add_child(level)
		
func on_level_removed(level:Node):
	if level != self and level.get_parent() != null:
		remove_child(level)
	elif(level.get_parent() == null):
		print_debug("level parent is null")
	else:
		print_debug("someone trying to detached world handler from itself")


func _ready():
	print_debug("I am ready")
	if world_seed == 0:
		world_seed = randi()


func change_level(new_level_data:Level_Data,handler:Node, instigator = null,
	location_offset = Vector2()
):
	#NOTE:player location for world position can be store in player handler
	#location offset may be ideal place to pass it since the tigger will be
	#passing a return point and could load it from player
	#the same gose for reverse.
	print_debug("changing level")
	level_data = new_level_data

#TODO: change name to: is_loaded_at or is_ready_at unless chunk end up sounding better
func is_chunk_loaded(location):
	if level_data != null:
		return level_data.is_level_loaded(location)
	return true

var player_pawns :Array[Node] = []


func _process(_delta):
	if level_data == null:
		return
	for pawn in player_pawns:
		if pawn == null:
			player_pawns.erase(pawn)
		elif pawn.is_in_group("player_controlled"):
			
			level_data.process_players(pawn)
			#TODO add some function to level data
			pass
		else:
			player_pawns.erase(pawn)

#NOTE: can get world location from HUD, but getting it here may be a bit odd
#also if server, kind of need to know about the player so this may be idea
func _on_child_entered_tree(node):
	#print_debug(node)
	if node.is_in_group("player_controlled"): #and !player_pawns.has(node):
		player_pawns.append(node)



func _on_child_exiting_tree(node):
	#print_debug(node)
	if player_pawns.has(node):
		player_pawns.erase(node)
