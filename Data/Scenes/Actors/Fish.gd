extends CharacterBody2D

@export var fish_name = "Fish"
@export var rare_catch = true
#should remane above as rare and instead of removing self iif catch, just treat this value as false
#or add a is_rare flag and single catch just store it location and remove if already fished
#probably should have catch_once seprated form rare_catch. then could
#have rare catach as a float so wilderness could make use of it

#should use the list here instead of a global class.
#could loop rare untill a fish is not found or use
#total rare fish caught as a base for the look up index
#should at least shuffle the list or find a random way to pick from the list
#could compare catches and then use a new array to pull from
#truth is having a reliable seed to geta  random rare from shuffle array be better
#but need lots of tests and a failsafe incase a same fish is pick (then probably pick one that have not been picked)
#array.shuffle()
@export var rare_fish_names = [
	"Rainbow Trout",
	"Moon Koi",
	"Black Bass",
	"Silver Guppy",
	"Shadow Pike",
	"Orange Eel",
	"Fade Barb",
	"King Walleye",
	"Killer Salmon",
	"Triple Perch",
	"Apple Carp",
	"Snake Eel", 
	"Doom Pike"
]
@export var common_fish_names = [
	"Carp",
	"Koi",
	"Bass",
	"Eel",
	"Barb",
	"Pike",
	"Perch",
	"Salmon",
	"Guppy",
	"Walleye",
	"Trout"
]

var starting_location

func _ready():
	starting_location = global_position
	if rare_catch:
		if Global.global_varibles.has("fish_" + str(starting_location)):
			remove_self()

func on_interact(_target):
	var data_source
	if _target.get_parent() is Player_Handler:
		data_source = _target.get_parent().player_state.metadata
	else:
		data_source = Global.global_varibles
		
	if rare_catch:
		if starting_location in data_source.unquie_fish_locations:
			print("fish already found, catching normal fish")
			if fish_name != "Fish":
				fish_name ="Fish"
				#changes name back to fish for special rares so tehy turn into normal fish
		else:
			if fish_name == "Fish":
				var checking_rare_fish = true
				var rare_fish_name
				if data_source["total_rare_fish_caught"] >= rare_fish_names.size():
					print("all rare fish should be caught now")
					rare_fish_name = rare_fish_names[randi() % rare_fish_names.size()]
					pass
				else:
					while checking_rare_fish:
						if rare_fish_names.size() > 0:
							rare_fish_name = rare_fish_names.pop_at(randi() % rare_fish_names.size())
							if data_source.has("fish_caught"):
								if data_source.fish_caught.has(rare_fish_name):
									print("have "+str(rare_fish_name) + ": " + str(data_source.fish_caught[rare_fish_name]))
									pass#skip
								else:
									checking_rare_fish = false
									pass#no fish
							else:
								checking_rare_fish = false
								pass#no data
						else:
							#may need to do an additanal check if all rares are caught and just repeat without the while
							rare_fish_name = "Silly Piranha" 
							checking_rare_fish = false
				fish_name = rare_fish_name
			#Global.rare_fish_count += 1
			if data_source.has("total_rare_fish_caught"):
				data_source["total_rare_fish_caught"] += 1
			else:
				data_source["total_rare_fish_caught"] = 1
			#if the fish have the generic name "fish", get a random one from a list. this should grab froma rare table
				pass
			data_source.unquie_fish_locations.append(starting_location)
		#Global.global_varibles["fish_" + str(starting_location)] = fish_name
	else:
		if fish_name == "Fish":
			fish_name = common_fish_names[randi() % common_fish_names.size()]
			#if the fish have the generic name "fish", get a random one from a list
			pass
		if data_source.has("fish_" + str(fish_name)):
			data_source["fish_" + str(fish_name)] += 1
		else:
			data_source["fish_" + str(fish_name)] = 1
		#Global.common_fish_count += 1
		if data_source.has("total_common_fish_caught"):
			data_source["total_common_fish_caught"] += 1
		else:
			data_source["total_common_fish_caught"] = 1
	#Global.message_box.set_message(fish_name)
	#should have the HUD handles this
	#probably a generic message function. type and data where type is if it a dialog, notify, or score
	#also can pass an amount incase more than one fish can be caught
	#Global.message_box.add_notify_message("[center]Caught " + str(fish_name))
	Global.get_hud().gui_notify.add_notify_message("[center]Caught " + str(fish_name))
	#Global.get_hud().$Notify.add_notify_message("[center]Caught " + str(fish_name))
	#add the fish to fish caught dict
	if data_source.has("fish_caught"):
		if data_source.fish_caught.has(fish_name):
			data_source.fish_caught[fish_name] += 1
		else:
			data_source.fish_caught[fish_name] = 1
	else:
		data_source.fish_caught = {fish_name:1}
	
	print("Caught " + fish_name)
	
	remove_self()
	
	
func remove_self():
	var self_ref = self
	get_parent().remove_child(self_ref)
	self_ref.queue_free()
