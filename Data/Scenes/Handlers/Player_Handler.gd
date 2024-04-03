class_name Player_Handler extends Node2D

@export var state : Player_State

@export_file("*.tscn") var default_pawn = "res://Data/Scenes/Actors/Player.tscn"

var pawn #pawn may be move around, so a direct ref will be used to track it
var uid = 0 #may or may not be needed if there a built in way to get a user id\

#catch the movement since the pawn moves every frame. 
var movement_input: Vector2


func _ready():
	#this is to test the signal
	#player_meta_changed.connect(player_meta_changed_test)
	
	if state == null :
		state = Player_State.new() 
		#this also could be where loading state happens if state is created when player 'joins'
	if pawn == null:
		#pawn_state = Pawn_State.Null
		#if has_node("Player"):
		#	pawn = $Player
			#pawn_state = Pawn_State.Init
			#set pawn to $player if it exist
			#good for testing and automatic set up,
			#but a function should be called instead
		#else:
		pawn = load(default_pawn).instantiate()
		pawn.add_to_group("player_controlled")
		General_Events.spawn_entity(pawn)
		#Game.world.add_child(pawn)
		#pawn_ref.name = "Player" #todo: make child of world main scene for objects
		#pawn = pawn_ref
	#TODO: need a func to possess and unpossesed pawns so the data
	#is correct.
	#players group is a group that holds all player pawns. used
	#for checking if a character is player own for cases where
	#actions are trigger only for players, but do not need a player_handler to work
	
	#pawn_state = Pawn_State.Alive
	#on_transfer()
	pawn.inventory.slot_update.connect(on_item_gain)




func _physics_process(_delta) :
	if pawn != null:
		pawn.move(movement_input)
		#this will be used unless a generic point can be predicted to use for the
		#pawn to move to


func input_update(event:InputEvent):
	#movement for the pawn(return is pawn is null
	if pawn != null :
		movement_input = Vector2(
			Input.get_axis("Left", "Right"),Input.get_axis("Forward","Back")
			).normalized()

		if event.is_action("Sprint"):
			pawn.movement_component.sprint_strength = event.get_action_strength("Sprint")
	#NOTE: facing direction is being ref here, and if pawn lacks it, it could be a problem
	#may need to make sure all pawns have it or find an indirect way to get a value
	#but it is in the base pawn movement so it may be fine for now
	#NOTEL: this came from player.any location or ref to self should be for pawn unless new
	#if pawn != null :
		if event.is_action("Accept") && event.is_action_pressed("Accept"):
			var space_state = get_world_2d().direct_space_state #can get a lot just with the player
			# use global coordinates, not local to node
			var query = PhysicsRayQueryParameters2D.create(
				pawn.global_position, 
				pawn.global_position+(pawn.movement_component.facing_dirction*24),
				0b10000000_00000000_00000000_00001000, #last is 1, first is 32
				[pawn])
			#NOTE: collsion mask may override each other. so if there two interact on one object for tracing
			#then only the first will trigger
			#0b10000000_00000000_00000000_00001101
			#query.exclude = [local_player]
			var result = space_state.intersect_ray(query)
			
			
			if "collider" in result:
			#	Game_Utility.get_action(result["collider"],"on_interact").call(
			#			self, pawn, result["collider"], {}
			#			)
			#	return #returning here to have it check tile for debug reason
			#	#ideally the source 'result["collider"]' would need to be coverted
			#	#to be used with tiles perhaps. or the logic can be push to Game_Utility
				if result["collider"] is TileMap :
					#below test for tilemap data. keeping for now so it be easier to
					#set up a tile base interaction system like search/forage/look/chop
					#print(result["rid"])
					#print(result["collider"].get_coords_for_body_rid(result["rid"]))
					#print(result["collider"].get_layer_for_body_rid(result["rid"]))
					#print(result["collider"].get_cell_tile_data(
					#	result["collider"].get_layer_for_body_rid(result["rid"]),
					#	result["collider"].get_coords_for_body_rid(result["rid"])
					#))
					pass
				else:
					var interaction_source := result["collider"] as Interactive_Component
					if interaction_source != null:
						var interaction = interaction_source.interact(
							self,pawn,interaction_source,{})


##Region Listerners
func on_item_gain(inventory, slot, old_item):
	#could leave this and just properly connect/disconnect on pawn change
	#the could check the new slot data
	#and if diffrent, run some logic like check if have fish name and of what
	#issue if the fish name is not added to item, the the fish logic would need to 
	#interact with the handler(like it kind of doing now) to do the check
	#NOTE: Big issue is that score is update when unable to store fish
	#but a check with the return value should fix that
	print("inv: "+ str(inventory))
	print("slot: "+ str(slot))
	print("old: "+ str(old_item))
	print("new: "+ str(inventory.items[slot]))

