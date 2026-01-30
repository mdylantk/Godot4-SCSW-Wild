class_name A_Start_Pounce_Fishing extends Base_Action

@export var random_table: Random_Table_Resource

@export var ui_state : UI_State = load('uid://dkc6l4f8ve4t5')


func _run(action_state:Action_State) -> bool:
	if random_table:
		ui_state.pounce_fishing_state.random_table = random_table
		#ui_state.pounce_fishing_state.interactor = action_state.owner
		ui_state.pounce_fishing_state.action_state = action_state
		ui_state.pounce_fishing_state.start.emit()
		action_state.is_referred = true
		return super(action_state)
	#TODO: add the fishing state to the ui state
	#acess that state and set the random table and other settings,
	#trigger the start logic, and then return true as long as everything ran
	return false
