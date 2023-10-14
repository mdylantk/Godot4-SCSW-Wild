class_name Inventory extends Node
#will depend on Item for item creation and checks
#probably will use an array for item storage. can filter it into an dictionary 
#if sorting is nessary, but array allow a fix sized
@export var size : int = 10
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
#			print("remaining: " + str(remaining_amount))
			if remaining_amount <= 0 and !is_removing:
				return remaining_amount
		elif other_item.is_empty() and !is_removing:
#			print("catching null item")
			empty_items.append(inventory_slot)
	if remaining_amount > 0:
#		print("looping null")
		if !empty_items.is_empty():
#			print("looping null")
			for null_slot in empty_items:
				items[null_slot] = item_type.new_item(item_type, 1, item["meta"])
				var null_item = items[null_slot]
#				print("null item : " + str(null_item))
				remaining_amount -= item_type.get_amount(null_item)
				if remaining_amount > 0:
#					print("adding amount: " + str(remaining_amount))
					remaining_amount = item_type.add_amount(null_item, remaining_amount)
#					print("remaining: " + str(remaining_amount))
					if remaining_amount <= 0:
						return 0
#	print("extending inventory")
	#NOTE: after hitting stack size it break and remainer is a negative number. need to see what went wrong
	if remaining_amount > 0 and items.size() < size:
		while remaining_amount > 0 and items.size() < size:
			items.append(item_type.new_item(item_type, 1, item["meta"]))
			var new_item = items[items.size()-1]
#			print("new item : " + str(new_item))
			remaining_amount -= item_type.get_amount(new_item)
			if remaining_amount > 0:
#				print("adding amount: " + str(remaining_amount))
				remaining_amount = item_type.add_amount(new_item, remaining_amount)
#				print("remaining: " + str(remaining_amount))
	return remaining_amount
