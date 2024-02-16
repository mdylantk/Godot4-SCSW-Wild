class_name Catch_Fish extends Interactive_Data

@export var random_table: Random_Table_Resource = Fish_Table.new()
@export var fish_item_source : Item = preload("res://Data/Resources/Fish_Item.tres")
#TODO: add a way to handle limited rares
#mostly to perserve the old system
#worst case the world handler can load static
#or templates that have fish that uses diffrent tables
#or have a catch rare action (or intergade it in this)
#pick_from_table()
func interact(handler, instigator, target, data):
	#random_table.fail_weight = 10
	print(random_table.fail_weight)
	var picked_name = {}
	picked_name = random_table.pick_from_table(true)
	if picked_name != null:
		var fish_name = picked_name["pick"]
		if fish_name == "":
			#todo send a message stating nothing was caught
			return false
		pass#name is know, so just need to create it
		var fish_item = fish_item_source.new_item(1,{"name":fish_name})
		var remaning_amount = Item_Events.acquire_item(instigator,fish_item,handler,"Caught")
		#TODO: need a way to log caught fish. this just statisitic like
		#number caught, biggest and smallest size caught, and such
		if picked_name["rarity"] < 3:
			var total_fish_caught = handler.get_player_meta("total_common_fish_caught")
			if total_fish_caught != null:
				handler.set_player_meta("total_common_fish_caught", total_fish_caught + 1)
			else:
				handler.set_player_meta("total_common_fish_caught", 1)
		else:
			var total_rare_fish_caught = handler.get_player_meta("total_rare_fish_caught")
			if total_rare_fish_caught != null:
				handler.set_player_meta("total_rare_fish_caught", total_rare_fish_caught + 1)
			else:
				handler.set_player_meta("total_rare_fish_caught", 1)
		return true
	return false
		
	#this is a replacement of the mess known as the fish logic
	#first thing is to pick a fish or the data needed to build a fish
	#then need to try to add the item to the player inventory as well
	#as update fish score. if none was catch, below is run instead
	#then send a message to the player stating if fish was caught or not
	#and if there is room in the inventory for it
	#then need to notify to perform an action on the fish in the world
	#like removing it, but returning a true or false value should be enough
	#so the fish can remove it self
