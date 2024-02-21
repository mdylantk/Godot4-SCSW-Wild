class_name AI_Handler extends Node2D

@export_file("*.tscn") var default_pawn = "res://Data/Scenes/Actors/Enemy_Test.tscn" #this should be an export when an enemy is made, 
#but this is the enemy to spawn. could be an array, but for testing this will be simple
var active_pawns #this may be replace by group if reliable
var max_spawn_count : int = 10
var spawn_delay : float = 15

func _ready():
	var pawn_ref = load(default_pawn).instantiate()
	add_child(pawn_ref)
	#pawn_ref.name = "Enemy" #todo: make child of world main scene for objects
	active_pawns = pawn_ref
	pawn_ref.hit.connect(on_pawn_hit)
	
func on_pawn_hit(pawn):
	if pawn.visible:
		pawn.visible = false
		set_process(false)
		await get_tree().create_timer(5.0).timeout
		pawn.visible = true
		set_process(true)


func _process(delta):
	if active_pawns != null:
		var target = Game.get_player_handler().pawn
		if target.global_position.length() > 16*32: #lazy way of having the logic run if player not in spawn
			var test_vector : Vector2 = target.global_position - active_pawns.global_position
			test_vector = test_vector * delta
			active_pawns.move(test_vector.normalized())
		
		#poor way to have enemy catch up to player after being hit
			if (active_pawns.global_position - target.global_position).length() > 320:
				active_pawns.sprint_strength = 8
			else:
				active_pawns.sprint_strength  = 0
		else:
			#when ever a pawn is not visable, it should enter a sleep state
			#or in this case visablity is used as a way to put it to sleep
			active_pawns.visible = false
			
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

