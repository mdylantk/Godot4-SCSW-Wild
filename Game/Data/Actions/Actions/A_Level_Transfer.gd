class_name A_Level_Transfer extends Base_Action

@export var level_uid : String
@export var spawn_location : Vector2 #not going to be used? can modify the player var if needed
@export var store_entry_point: bool = false
#entry point would still need to be stored in a dictionary or array
#since it is memorozing the entry point to be used later when exiting
#note: may need to use a vector action/resource for the position saved
#so there is more controll over it.
@export var entry_point_id:StringName = "world"
#todo should have an exit data object/resource that states
#where to spawn in the next level. this may need to be save as well
#probably in the player state since it is related to the player character
#but may need to be pass to world so world wont need to acess player
@export var spawn_index : int = 0

@export var world_events : Events_World = load('uid://b047ftosxvj7p')
@export var player_state : Player_State = load('uid://c67c2fehtuhni')

#NOTE: need a better way to handle player position
#could split the action. one to store position, then level switch(this logic), and
#then relocate player. also could have this store and relocate, but need a way to handle
#relocate. either by id or fix value. could have it use an action or just keep the action seprated

#also could add entry points to level data or just have level data handles where the 
#player spawns. also may need to let the handler knows there a levels switch, but
#the world probably should handle that


func _run(data:Action_State = null) -> bool:
	if level_uid != "":
		#var handler : Node = data["handler"]
		#var instigator : Node  = data["source"]
		#var new_location : = Vector2()
		if data == null:
			return false
		if data.owner as Node2D:
			var old_location : Vector2 = data.owner.global_position
			print_debug(player_state, Player.save_state, player_state == Player.save_state)
			if store_entry_point:
				player_state.positions[entry_point_id+"_location"] = old_location
				#Savedata_Helper.store_player_position(Player,old_location,entry_point_id)
				#Player.state.store(entry_point_id,old_location,"positions")
			if (data.owner as Character2D):
				player_state.exit_data.facing_direction = (data.owner as Character2D).facing_direction
			player_state.exit_data.entry_position = old_location
				
				
		else:
			#may not want to return if not node2d?
			return false
		#player_state.exit_data.entry_diection
		#player_state.exit_data.entry_velocity
		player_state.exit_data.target_level = level_uid
		world_events.load_level.emit(level_uid, spawn_index)
		#var level_loaded : Base_Level = World.load_level(level_uid, spawn_index) #should return bool to see if it ran
	return super(data)
