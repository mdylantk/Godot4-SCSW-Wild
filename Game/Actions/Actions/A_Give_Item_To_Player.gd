##Gives an item to the player state
class_name A_Give_Item_To_Player extends Base_Action

##The item or item template to give to the player.
@export var item : Item 
##Use a copy if the provide item to allow endless use
##as long as this instance is active
@export var use_copy : bool = true
##Will send a notify message on item gain or loss
##NOTE: This may be changed to an int (enum) for various notifcations flags
##such as on gain, on change, and anything else that may be needed 
@export var notify : bool = true
##drop an item in the world if the inventory is unable to accept all
##NOTE: this will be added once item enties are made and the world state
##accept spawning events. for now this is a place holder
@export var drop_overflow_item : bool = true


##The player state override. Use for debugging or if state exist in a diffrent place
## but may use a multiplayer interface that can interact with the non-local player state.
##NOTE: multiplayer is not in the project scope
@export var player_state : Player_State = load('uid://c67c2fehtuhni')
@export var ui_state : UI_State = load('uid://dkc6l4f8ve4t5')

func run(data:Action_State) -> bool:
	var item_starting_amount : int
	var amount_used: int 
	if item == null:
		return false
	item_starting_amount = item.amount
	#TODO: decide on a name for the item that is left over
	if use_copy:
		var item_copy : Item = item.duplicate()
		player_state.add_item(item_copy)
		amount_used = item_starting_amount - item_copy.amount
		data.set_data('item_remaining',item_copy)
		#data.set_meta('item_remaining',item_copy)
	else:
		player_state.add_item(item)
		amount_used = item_starting_amount - item.amount
		data.set_data('item_remaining',item)
		#data.set_meta('item_remaining',item)
	#NOTE TODO: need to make sure this uses translation words ideally in a formated
	#string like 'acquire {item}' also should probably strip the [center] and apply
	#it in the ui
	#TODO: in notify, allow a numeric value for amount of calls
	#since notify adds x number of times at the end. then again
	#change it to put the number between the change type and item name
	#so it should not look as bad, but may flow better if an amount is passed
	#yet also could lead to really large numbers
	if amount_used > 0 and notify:
		var message:String = "[center]"+"Acquired "+ item.item_type.display_name
		if amount_used > 1:
			message = "[center]"+"Acquired "+ str(amount_used) +' ' + item.item_type.display_name
		ui_state.send_notifcation.emit(message)
		#notify item was gain plus amount
		pass
	elif amount_used < 0 and notify:
		var message:String = "[center]"+"Loss "+ item.item_type.display_name
		if amount_used < -1:
			message = "[center]"+"Loss "+ str(abs(amount_used)) +' ' + item.item_type.display_name
		ui_state.send_notifcation.emit(message)
		#notify item was removed
		pass
	return true
	
	#return super(data)
