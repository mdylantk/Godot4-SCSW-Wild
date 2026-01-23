class_name A_Set_Player_Variables extends Base_Action

@export var group : String = "meta"
##NOTE: this need to have string keys
##TODO: update to a type dictionary. will need to make sure
##existing data do not get erased
@export var variables : Dictionary
@export var player_state : Player_State = load('uid://c67c2fehtuhni')

func _run(action_state:Action_State) -> bool:
	#NOTE: need to hande each case for the state.
	#this will be for any data, but not going to work
	#for typed data (like score or positions)
	for key in variables.keys():
		
		player_state.set_data(key,variables[key])
	return super(action_state)
