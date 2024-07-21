class_name Inventory_Handler extends Node
#data is ment to be an object/dictonary. aka event_data. this hold data that may be needed
#elsewhere. acts like a metadata that can be extended upon if needed
#handler is the ref to a controller that trigging it
#source is the node that own the inventory node
#item is a copy of the item change. most likly a new resource 
#note that the signal is called after a modifcation (if any)
#NOTE: inventory may still send similar signals, so this
#can be a singlton (or only one exists) and focus more on the triggers
#than the reponce(signals for logging and upper level listing instead of reconnecting
#to a controlls or pawns inventory on a change or in cases where the handler is needed to be known
#so that inventory signals can be simplified(return item change, but no data on who or how)
signal item_acquired(handler, source, item, data)
signal item_remove(handler, source, item, data)

###NOTE:
#this is ment to try to isolate the item system from this game
#this will act like an event bus for item action
#as well as provide trigger functions (which the action will connect to)
#in a sence it would replace Item_Events and act as an active object(node)
#which may be an autoload or a child of an autoload (game_handler most likly)

#the only issue is that it be more abstract when listing to an item event then having
#the controller handlers handle it...unless the handler will each own one inventory handler
#which would allow the logic to be seprated, but also would need the logic act as if it is owned
#which mean the game would need to connect to all players inventory signals if it want to
#log all actions. may be better that way

#handles adding and removing an item
#using source and then will fetch inventory so no prestep is needed
func add_item(handler:Node, source:Node, item:Item, amount:int = 1, data:={}):
	var inventory : Inventory
	for child in source.get_children():
		if child is Inventory:
			inventory = child
			break
	if inventory == null:
		print_debug("dose not have inventory")
		return
	#print_debug("adding item: " +str(item) + "+("+str(amount)+")")
	var remaining_amount = inventory.add_to_inventory(item,amount)
	#will trigger an add item to inventory(or maybe find inventory of target if needed)
	#invetory should have a func to do that so it can be overriden. 
	#most of the logic it call by default should be the below default
	pass

static func increase_item_amount(item, amount) -> int:
	var total_amount : int = item.amount + amount
	var remaining_amount : int = amount
	if remaining_amount == 0:
		return 0
	elif remaining_amount > 0:
		remaining_amount = max(total_amount-item.max_stack_size,0)
		item.amount = min(total_amount, item.max_stack_size)
		#if amount > max_stack_size:
			#amount_overflow.emit(remaining_amount)
	else:
		remaining_amount = min(total_amount,0)
		item.amount = max(total_amount, 0)
		if item.amount <= 0:
			#there a chance items may not need signals. inventory and inventory handler
			#probably can handle it
			#like this should be called after that static func call and emit signal there
			item.amount_depleted.emit()
			
	#TODO check if this works
	return remaining_amount
	
static func is_similar_item(item, other_item) -> bool:
	if other_item == null: return false
	
	if (is_same_item(item, other_item)):
		if item.get_meta_list().is_empty() and other_item.get_meta_list().is_empty():
			return true
		elif item.get_meta_list().size() != other_item.get_meta_list().size():
			return false
		else:
			for key in item.get_meta_list():
					#NOTE: resources might break this so it may be best to
					#either not use resources/object or stress test it with 
					#a resource case
				var self_value = item.get_meta(key)
				var other_value = other_item.get_meta(key)
				if typeof(self_value) == typeof(other_value):
					if item.get_meta(key) != other_item.get_meta(key):
						return false
				else:
					return false
			return true
	return false
	
static func is_same_item(item, other_item)->bool:
	if (item.display_name == other_item.display_name and
		item.discription == other_item.discription and 
		item.tooltip == other_item.tooltip and 
		item.icon == other_item.icon
	):
		return true
	return false

