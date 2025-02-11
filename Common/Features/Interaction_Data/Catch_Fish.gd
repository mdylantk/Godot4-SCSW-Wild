class_name Catch_Fish extends Interactive_Data

@export var random_table: Random_Table_Resource = Fish_Table.new()
@export var fish_item_source : Item_Type = preload("uid://nrh8trhov6yk")

var fish_game
#var fisher
#var fisher_handler


func _run():
	_start()

#func interact(handler, instigator, interactee, data):
func _start():
	#random_table.fail_weight = 10
	#fisher = instigator
	#fisher_handler = handler
	#TEST
	#note: only one fish game per action...but only one should exist if not
	#dynamicly added
	if fish_game == null:
		fish_game = UI.fishing_game
		#fish_game.add_fish(Vector2i(24,24),fish_game.rare_fish_atlas_coords,2,
		#	{"move_rate":randf_range(.5,1),"type":"rare fish"}
		#)
		fish_game.catched.connect(on_catch)
		fish_game.missed.connect(on_miss)
		fish_game.canceled.connect(on_cancel)
		
		for count in range(randi_range(5,15)):
			var type = pick_fish()
			var layer = 1
			var move_rate = randf_range(.001,0.3)
			var picked_coords = fish_game.get_water_coords().pick_random()
			if type["pick"] == null:
				break
			if type["rarity"] >= 3: 
				layer = 3
				move_rate = randf_range(.5,1)
			else:
				layer = type["rarity"]
			fish_game.add_fish(picked_coords, fish_game.default_fish_atlas_coords, layer,
				{"move_rate":move_rate,"type":type}
			)
		fish_game.resume()
	
	
	#TEST END
func pick_fish():
	var picked_name = {}
	if random_table == null : random_table = Fish_Table.new()
	picked_name = random_table.pick_from_table(true)
	if picked_name != null:
		var fish_name = picked_name["pick"]
		return picked_name
		if fish_name == "":
			#todo send a message stating nothing was caught
			return false
		pass#name is know, so just need to create it

func add_fish(fish_data:Dictionary):
	if !fish_data.is_empty():
		print_debug(fish_data["type"])
		data["fish_data"] = fish_data
		var fish_name = "fish"
		var new_fish_item = Item.new()
		if fish_data["type"]["pick"] as Item_Type:
			print_debug("MEOW IT IS A FISH!!!")
			fish_name = fish_data["type"]["pick"].display_name
			new_fish_item.type = fish_data["type"]["pick"]
		else:
			fish_name = fish_data["type"]["pick"]
		#var fish_item = fish_item_source.new_item(1,{"name":fish_name})
			new_fish_item.type = fish_item_source
			new_fish_item.set_meta("unique_name",fish_name)
		##NOTE: segment trying to add a test of the new item system
		#new_fish_item.type = load("uid://nrh8trhov6yk") as Item_Type
			
		
		var inventory : Inventory
		if interactor as Character2D:
			inventory = interactor.get_inventory()
		else:
			#old logic, may be fine for some systems, but most enities
			#should have some kind of inventory interface
			print_debug("MEOOW THIS SHOULD NOT BE CALLED. planing on disabling it")
			#may disable this temp since things that interact mostly will be characters
			#though non characters might have in inventory, but acessing it would be diffrent
			for child in interactor.get_children():
				if child is Inventory:
					inventory = child
					break
		if inventory == null:
			print_debug("dose not have inventory")
		var remaining_amount = inventory.add_to_inventory(new_fish_item,1)
		#InventoryHandler.add_item(handler,interactor,new_fish_item)
		#TODO: let the inventory handle notify? or check if the item was added
		UI.gui_notify.add_notify_message("[center]"+"Acquired "+ fish_name )
		#var remaning_amount = Item_Events.acquire_item(interactor,fish_item,handler,"Caught")
		#TODO: need a way to log caught fish. this just statisitic like
		#number caught, biggest and smallest size caught, and such
		
		if fish_data["type"]["rarity"] < 3:
			#var total_fish_caught = handler.state.fetch("total_common_fish_caught")
			var total_fish_caught = Savedata_Helper.fetch_player_score(handler,"common_fish_caught")
			
			#if total_fish_caught != null:
			#	handler.state.store("total_common_fish_caught", total_fish_caught + 1)
			#else:
			#	handler.state.store("total_common_fish_caught", 1)
			Savedata_Helper.store_player_score(handler, total_fish_caught + 1, "common_fish_caught")
			
		else:
			#var total_rare_fish_caught = handler.state.fetch("total_rare_fish_caught")
			var total_rare_fish_caught = Savedata_Helper.fetch_player_score(handler,"rare_fish_caught")
			#if total_rare_fish_caught != null:
			#	handler.state.store("total_rare_fish_caught", total_rare_fish_caught + 1)
			#else:
			#	handler.state.store("total_rare_fish_caught", 1)
			Savedata_Helper.store_player_score(handler, total_rare_fish_caught + 1, "rare_fish_caught")
		
		#protype fishlog
		#Note: the proper system would use a log resource of fish resource
		#with an entrie resource
		log_fish(handler, fish_name, fish_data["type"]["rarity"], {"count":1})
		#print("fish log debug")
		#print_debug(handler.state.data)

#NOTE: new_handler is not needed since it should be set as handler
func log_fish(new_handler, name, rarity, new_fish_data):
	#TODO: change or remove this. this is a prototype log.
	#should add a statistics system
	var fish_data = new_handler.state.fetch(name, "fish_log_"+str(rarity))
	if fish_data == null:
		new_handler.state.store(name,new_fish_data, "fish_log_"+str(rarity))
		return
	if new_fish_data.has("count"):
		if fish_data.has("count"):
			fish_data["count"] += new_fish_data["count"]
		else:
			fish_data["count"] = new_fish_data["count"]
			
func on_catch(fish_data:Dictionary):
	add_fish(fish_data)
	end_game(false)#, fish_data)


func on_miss(vaild:bool = false):
	if vaild == true:
		General_Events.send_notifcation("Failed to catch a fish.")
		end_game()

func on_cancel():
	end_game(true)

func end_game(cancel : bool = false):#, fish_data:Dictionary = {}):
	fish_game.end()
	fish_game.catched.disconnect(on_catch)
	fish_game.missed.disconnect(on_miss)
	fish_game.canceled.disconnect(on_cancel)
	fish_game = null
	#fisher = null
	#fisher_handler = null
	end_interact(cancel)
