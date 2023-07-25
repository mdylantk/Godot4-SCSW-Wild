extends Node

#NOTE since there are ref, then they need to be cleared if any of the object are needed to be removed
var local_player #link the player character of the client game
var player_state = [] #a scene or resource to handle player data indepentent of the player pawn. as a dict inscae other players need to be known about

var game_state #link a node to handle world changes (session base, not level)

var dialog #a global ref to the dialog window. this really should be the hud or the playerstate should house the hud
var message_box

var rare_fish_count = 0
var rare_fish_list = [
	"Rainbow Trout",
	"Moon Koi",
	"Black Bass",
	"Silver Guppy",
	"Shadow Pike",
	"Orange Eel",
	"Fade Barb",
	"King Walleye",
	"Killer Salmon",
	"Triple Perch",
	"Apple Carp",
	"Snake Eel", 
	"Doom Pike"
]

var common_fish_count = 0
var common_fish_list = [
	"Carp",
	"Koi",
	"Bass",
	"Eel",
	"Barb",
	"Pike",
	"Perch",
	"Salmon",
	"Guppy",
	"Walleye",
	"Trout"
]

var global_varibles : Dictionary = {} #type:id so dialog:old_man would preprent the dialog state of the old man
#var level #the current level. in this case the active tile map or it's parent #can get this from the player parent
#Will try to assume most characters will have CharacterMovement(can check if it has var

#func _process(_delta):
#	if local_player == null:
##		if get_viewport().get_camera_2d() != null :
#			local_player = get_viewport().get_camera_2d().get_parent()
#			#may need to have a check or just make sure a heirarchy is followed
#func _input(event) :
	#if event.is_action("Accept") && event.is_action_pressed("Accept"):
	#if Input.is_action_pressed("Accept"):
		#print("meow")
		#print(local_player.get_parent().get_cell_tile_data(1,local_player.get_parent().local_to_map(local_player.local_position)))
		#var tilemap = local_player.get_parent()
		#print(tilemap)
		#var map_pos = tilemap.local_to_map(local_player.position)# + Vector2i(facing_direction)
		#the offset works, but checks should check self first (or last) so two check incase teh collsion is small
		
		#print(map_pos)
		#var tile_data = tilemap.get_cell_tile_data(0,map_pos)
		#current_tile = tile_data
		#forward_tile = tilemap.get_cell_tile_data(0,map_pos + Vector2i(local_player.facing_dirction))
		#print(current_tile)
		#print(forward_tile)
		#var source_id = tilemap.get_cell_source_id(0,map_pos)
		#print(source_id)
		#tilemap.set_cell(0,map_pos,source_id,Vector2i(0, 0))
		#note: need to het various info
		#the most inpointain is the source id and tile atlas vector(2i)
		#also this just replace a static tile with another staic tile
		#map pos need to be offset if want to target stuff infront
		#if local_player == null :
		#	return #WARNING, this be bad if function that do not need player happens below this
		#var space_state = local_player.get_world_2d().direct_space_state #can get a lot just with the player
		# use global coordinates, not local to node
		#var query = PhysicsRayQueryParameters2D.create(
		#	local_player.global_position, 
		#	local_player.global_position+(local_player.facing_dirction*16),
		#	0b10000000_00000000_00000000_00000001, #last is 1, first is 32
		#	[local_player])
		#0b10000000_00000000_00000000_00001101
		#query.exclude = [local_player]
		#var result = space_state.intersect_ray(query)
		#if "collider" in result:
		#	if result["collider"] is TileMap :
		#		print(result["rid"])
		#		print(result["collider"].get_coords_for_body_rid(result["rid"]))
		#		print(result["collider"].get_layer_for_body_rid(result["rid"]))
		#		print(result["collider"].get_cell_tile_data(
		#			result["collider"].get_layer_for_body_rid(result["rid"]),
		#			result["collider"].get_coords_for_body_rid(result["rid"])
		#		))
		#	else:
		#		print(result["collider"])
