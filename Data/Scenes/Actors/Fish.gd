extends CharacterBody2D

@export var fish_name = "Fish"
@export var rare_catch = true

@export var fish_item : Item

#NOTE: should have randomrarefish in random ponds but they should be of caught fishes
#or a flag/state that state if the void world effect fish type or pick from availbe types
#just a random of caught fishes could be used
#but it would be any fishm not just rare so the chance could be higher
#but may need to seprate rare and common to simplfy score stuff maybe
#or have a rare counter that tally up first catch (provbably better at the cost of a little extra memory)
#may need that for common fish+


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
	#if rare_catch:
	#	if Global.global_varibles.has("fish_" + str(starting_location)):
	#		remove_self()

#probably could use interact data for this. item pickup. just need a way to update score
#so maybe am extended one for this case
func on_interact(handler, instigator, target, data):
	var data_source
	if handler is Player_Handler:
		data_source = handler.state.metadata
	else:
		data_source = Global.global_varibles
		
	if starting_location in data_source.unquie_fish_locations:
		#flagging rare off so it treated as common.
		rare_catch = false
		#also reset the name
		#but probably should have a flag to state if it a rare name
		#which in this case it would be or it would not be tagged as rared
		fish_name == "Fish"
	if rare_catch:
		#changes name back to fish for special rares so tehy turn into normal fish
		#else:
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
	
	if instigator != null:
		var remaining_amount = instigator.inventory.add_item(Item.new_item(fish_item, 1,{"name":fish_name}))
		if remaining_amount >= 1:
			print("can not carry anymore fish")
	
	if handler != null: 
		#TODO: maybe player_hander should have a hud if the client. maybe a hud for each player for splitscreen?
		handler.get_hud().gui_notify.add_notify_message("[center]Caught " + str(fish_name))
	#Global.get_hud().$Notify.add_notify_message("[center]Caught " + str(fish_name))
	#add the fish to fish caught dict
	var count = handler.get_player_meta(fish_name+" caught")
	if count != null:
		handler.set_player_meta(fish_name+" caught", count + 1)
	else:
		handler.set_player_meta(fish_name+" caught", 1)
#	if data_source.has("fish_caught"):
#		if data_source.fish_caught.has(fish_name):
#			data_source.fish_caught[fish_name] += 1
#		else:
#			data_source.fish_caught[fish_name] = 1
#	else:
#		data_source.fish_caught = {fish_name:1}
	
	#print("Caught " + fish_name)
	
	remove_self()
	

func remove_self():
	var self_ref = self
	get_parent().remove_child(self_ref)
	self_ref.queue_free()
