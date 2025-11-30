class_name Savedata_Helper extends Object

#NOTE TODO: this is not going to be used. will used resources at fix spots
#to get info about things. save will be handle by the owner of the object as well
#with some help from the game or a save/data handler for figuring out the correct
#path

static func store_player_position(handler:Player_Handler,new_location:Vector2,id:StringName):
	if Player.state:
		Player.state.positions[id+"_location"] = new_location
	
static func fetch_player_position(handler:Player_Handler,id:StringName)->Vector2:
	if Player.state:
		if Player.state.positions.has(id+"_location"):
			return Player.state.positions[id+"_location"]

	return Vector2()
