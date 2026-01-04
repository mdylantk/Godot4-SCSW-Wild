##Gives an item to the player state
class_name A_Give_Item_To_Player extends Base_Action

##The item or item template to give to the player.
@export var item : Item 
##Use a copy if the provide item to allow endless use
##as long as this instance is active
@export var use_copy : bool = true


##The player state override. Use for debugging or if state exist in a diffrent place
## but may use a multiplayer interface that can interact with the non-local player state.
##NOTE: multiplayer is not in the project scope
@export var player_state : Player_State = load('uid://c67c2fehtuhni')

func run(data:Action_State = null) -> bool:

	if item == null:
		return false
	if use_copy:
		var item_copy = item.duplicate()
		player_state.add_item(item_copy)
		data.set_meta('item_remaining',item_copy)
	else:
		player_state.add_item(item)
		data.set_meta('item_remaining',item)
	return true
	
	#return super(data)
