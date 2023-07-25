extends CharacterBody2D

@export var fish_name = "Fish"
@export var single_catch = true
var starting_location

func _ready():
	starting_location = global_position
	if single_catch:
		if Global.global_varibles.has("fish_" + str(starting_location)):
			remove_self()

func on_interact(_target):
	if single_catch:
		if fish_name == "Fish":
			if Global.rare_fish_list.size() > 0:
				fish_name = Global.rare_fish_list.pop_at(randi() % Global.rare_fish_list.size())
			else:
				fish_name = "Silly Piranha"
			Global.rare_fish_count += 1
			#if the fish have the generic name "fish", get a random one from a list. this should grab froma rare table
			pass
		Global.global_varibles["fish_" + str(starting_location)] = fish_name
	else:
		if fish_name == "Fish":
			fish_name = Global.common_fish_list[randi() % Global.common_fish_list.size()]
			#if the fish have the generic name "fish", get a random one from a list
			pass
		if Global.global_varibles.has("fish_" + str(fish_name)):
			Global.global_varibles["fish_" + str(fish_name)] += 1
		else:
			Global.global_varibles["fish_" + str(fish_name)] = 1
		Global.common_fish_count += 1
	Global.message_box.set_message(fish_name)
	
	print("Caught " + fish_name)
	
	remove_self()
	
	
func remove_self():
	var self_ref = self
	get_parent().remove_child(self_ref)
	self_ref.queue_free()
