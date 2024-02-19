class_name Inventory extends Node

#added/remove may become add/remove signal/event or not added at all
#signal item_added(handler, item, data)
#signal item_removed(handler, item, data)
signal slot_update(inventory, slot, old_item)

#will depend on Item for item creation and checks
#probably will use an array for item storage. can filter it into an dictionary 
#if sorting is nessary, but array allow a fix sized
@export var size : int = 100
@export var items : Array[Dictionary]


func add_item(item : Dictionary):
#	print("trying to add item: " + str(item))
	var item_type = Item.get_type(item)
	var remaining_amount = item_type.get_amount(item)
	var is_removing = remaining_amount < 0
	var empty_items : Array[int] = []
	#note: item type should be an class or have item func. it may be better to use that than Item since
	#then other types can override the logic
#	print("looping inventory")
	for inventory_slot in range(items.size()):
		var other_item = items[inventory_slot]
		if is_removing:
			other_item = items[items.size()-1-inventory_slot]
	#for other_item in inventory:
		if item_type.is_similar_item(item, other_item):
#			print("adding amount: " + str(remaining_amount))
			remaining_amount = item_type.add_amount(other_item, remaining_amount)
			slot_update.emit(self, inventory_slot, other_item.duplicate(true))
			if remaining_amount <= 0 and !is_removing:
				break
				#return remaining_amount
		elif other_item.is_empty() and !is_removing:
#			print("catching null item")
			empty_items.append(inventory_slot)
			slot_update.emit(self, inventory_slot, other_item.duplicate(true))
	if remaining_amount > 0:
#		print("looping null")
		if !empty_items.is_empty():
#			print("looping null")
			for null_slot in empty_items:
				items[null_slot] = item_type.new_item(1, item["meta"])
				var null_item = items[null_slot]
#				print("null item : " + str(null_item))
				remaining_amount -= item_type.get_amount(null_item)
				if remaining_amount > 0:
#					print("adding amount: " + str(remaining_amount))
					remaining_amount = item_type.add_amount(null_item, remaining_amount)
					slot_update.emit(self, null_slot, {})
#					print("remaining: " + str(remaining_amount))
					if remaining_amount <= 0:
						break
						#return 0
						#todo figure out why was returning 0
				else:
					slot_update.emit(self, null_slot, {})
#	print("extending inventory")
	#NOTE: after hitting stack size it break and remainer is a negative number. need to see what went wrong
	if remaining_amount > 0 and items.size() < size:
		while remaining_amount > 0 and items.size() < size:
			items.append(item_type.new_item(1, item["meta"]))
			var new_slot = items.size()-1
			var new_item = items[new_slot]
#			print("new item : " + str(new_item))
			remaining_amount -= item_type.get_amount(new_item)
			if remaining_amount > 0:
#				print("adding amount: " + str(remaining_amount))
				remaining_amount = item_type.add_amount(new_item, remaining_amount)
				slot_update.emit(self, new_slot, {})
#				print("remaining: " + str(remaining_amount))
			else:
				#this is here so it oly get called once
				slot_update.emit(self, new_slot, {})
	#slot_update.emit(self, -1, {})
	return remaining_amount
