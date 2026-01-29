##set the action data 'picked_table_data' to what was picked in the 
##provided table. Next chain action or the node that called this
##can then use that data key as it wish.
class_name A_Pick_Random_From_Table extends Base_Action

@export var table : Random_Table_Resource

func _run(action_state:Action_State) -> bool:
	if table:
		action_state.set_data('picked_table_data',table.pick_from_table(true))
		return true
	return false
