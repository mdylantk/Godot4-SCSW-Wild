class_name AI_Handler extends Controller_Handler

#@export var default_pawn : PackedScene = load("uid://bruyakjvb8wwp")  
@export var controller_name : String = "enemy"
@export var state : Savable_State :
	set(value):
		state = value
		state.file_name = controller_name+"_state"
		
@export var enable : bool 
#but this is the enemy to spawn. could be an array, but for testing this will be simple
var active_pawns: Array[Node] #this may be replace by group if reliable
var max_spawn_count : int = 10
var spawn_delay : float = 15


func get_state()->Savable_State:
	return state
func get_pawn(index:int=0)->Node:
	return active_pawns[index]

func handle_pawn(pawn:Node)->void:
	if !active_pawns.has(pawn):
		active_pawns.append(pawn)
		pawn.attacked.connect(on_pawn_hit)

func unhandle_pawn(pawn:Node)->void:
	if active_pawns.has(pawn):
		active_pawns.erase(pawn)
		pawn.attacked.disconnect(on_pawn_hit)
	pass

func _ready():
	if !enable: return
	#var pawn_ref = default_pawn.instantiate()
	#World.add_child(pawn_ref)
	#handle_pawn(pawn_ref)
	super()

#NOTE: this was a test. new system should let the pawn handle itm
#but the controller could allow requests that the handler can listen to
#or set the value directly
#TODO: on_pawn_hit is not needed unless used as a notify
#but even then should use controller for communication
func on_pawn_hit(attacker, target, data):
	if target.visible:
		target.visible = false
		set_process(false)
		await get_tree().create_timer(5.0).timeout
		target.visible = true
		set_process(true)

			
func _process(delta):
	var player = null
	var players:Array[Node] = get_tree().get_nodes_in_group("Player_Pawns")
	if players.size() > 0:
		player = players[0]
		#brain.set_meta(&"move_to",player)
	
	if controller and player != null:
		controller.set_meta(&"move_to",player) 
