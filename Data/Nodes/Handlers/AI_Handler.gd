class_name AI_Handler extends Controller_Handler

@export var default_pawn : PackedScene = load("uid://bruyakjvb8wwp")  
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
	var pawn_ref = default_pawn.instantiate()
	World.add_child(pawn_ref)
	handle_pawn(pawn_ref)
	super()

func on_pawn_hit(attacker, target, data):
	if target.visible:
		target.visible = false
		set_process(false)
		await get_tree().create_timer(5.0).timeout
		target.visible = true
		set_process(true)

func on_ai_update():
	for pawn in active_pawns:
		if pawn.brain_component != null:
			pawn.brain_component.update(pawn,self)
			
func _process(delta):
	#TODO need the world_handler to frezze(pause) it children when no level_data
	#or when loading new areas
	if active_pawns.size() <= 0: return
	var pawn = active_pawns[0]
	if pawn != null:
		var target = Player.pawn
		if target.global_position.length() > 16*32: #lazy way of having the logic run if player not in spawn
			if pawn.brain_component is AI_Controlled_Brain:
				var brain : AI_Controlled_Brain = pawn.brain_component as AI_Controlled_Brain
				#brain.move_to_location = target.global_position
				brain.set_meta(&"move_to",target)
				#maybe store data like move to location as a metadata?
				#could store it as a vector or node2d at the cost of checking first
				#brain.update(pawn)
			on_ai_update()
			
			
			var test_vector : Vector2 = target.global_position - pawn.global_position
			pawn.visible = true 
			test_vector = test_vector * delta
			#pawn.move(test_vector.normalized())
		
		#poor way to have enemy catch up to player after being hit
			if (pawn.global_position - target.global_position).length() > 320:
				pawn.movement_component.sprint_strength = 8
			else:
				pawn.movement_component.sprint_strength  = 0
		else:
			#when ever a pawn is not visable, it should enter a sleep state
			#or in this case visablity is used as a way to put it to sleep
			pawn.visible = false
			pass
			
		#NOTE:could have it location change if target too far as well as add an
		#interaction event where it will teleport when hit
		
		#the true goal is have the enemy fly at the player with a random offset
		#and then removed(or relocated)
		#but also it can not spawn or go near spawn and within a certain radius of spawn
		#they are ment to steal fish. 
		#the player could swat them away 
		#maybe bodies of water will prevent spawning too
		
		#this is a simple idea for a conflict, but there is no loss 
		#from running out of fish so more may be needed
		#maybe bringing back the fish to the old man will improve his mood
		#but lore wise, the fish seen would populate the pond. also could add
		#health and fish can heal it. mostly for cases for more hostile enemies
		#the cat may engage. but lore wise the cat is undying, so only inventory
		#would be lost on defeat and the cat will spawn at spawn.
		
		#adding ncp and town grown would allow fish to be a for of currancy since the old man
		#probably would not want to fish for everyone (or just can not fish enough) 
		#so a form of mood booster or currancy
		
#this is similar to the player handler, but
#it controlls AI enities or at least regulate then
#pass what their AI can do
#handle factions, plan squad like movements, and such

#due to this needing to be design, much of the functionaly will be temp
#since this should be bare bones and wnything that extends from it should
#have the bulk logic

#current goal: check and spawn enemies and give them goals. 
#this require game to feed infomation to this. mostly a location in the 
#world. a signal or a global event would be needed to request spawning an 
#enitiy. also a target, but location and target can be shared since they are the
#same since they should only spawn in loaded chunks which is center around players
#but that mostly for the test AI. real AI may need more stuff like hook to let 
#it know when a pawn it owns spawns or despawns. may be ideal to use groups for
#this case
