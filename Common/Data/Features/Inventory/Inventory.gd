class_name Inventory extends Node

#added/remove may become add/remove signal/event or not added at all
#signal item_added(handler, item, data)
#signal item_removed(handler, item, data)
signal slot_update(inventory, slot, old_item)

#TODO: new system may listen to item events to auto add or remove item (such are adding more
#than max stack size will tigger a signal. same when depleting an item)
#this should also make the inventory send a signal if the item can not be removed
#or even if there not enough of the item(though the use for the latter is unknown
#NOTE: Ignore above(kind of) should listen to depleted so the item can be removed
#but the inventory should handle creating new ones and adjusting values so the
#data is more directly accessable. 


#will depend on Item for item creation and checks
#probably will use an array for item storage. can filter it into an dictionary 
#if sorting is nessary, but array allow a fix sized
@export var size : int = 100

@export var inventory : Array[Item]

#NOTE: unable to get path or uid of resource in code
#so saving resources is more ideal dispite being able to be modified
#for a safer way, a item array would be needed and manually assign items
#to an id.



func add_to_inventory(new_item:Item, amount : int = 1) -> int:
	var remaining_amount : int = amount
	var trash_items : Array[Item]
	if remaining_amount > 0:
		#todo: may need to get the slot id for this
		for item in inventory:
			if item.is_similar_to(new_item):
				remaining_amount = item.increase_amount(remaining_amount)
				#if item.amount <= 0:
				#	trash_items.append(item)
				slot_update.emit(self,0,item)
		for new_slot in range(100-inventory.size()):
			if remaining_amount > 0:
				var new_item_stack : Item = new_item.duplicate()
				var new_amount = remaining_amount
				if remaining_amount > new_item_stack.max_stack_size:
					new_amount = new_item_stack.max_stack_size
					remaining_amount = remaining_amount - new_item_stack.max_stack_size
				else:
					new_amount = remaining_amount
					remaining_amount = 0
				new_item_stack.amount = new_amount
				inventory.append(new_item_stack)
				slot_update.emit(self,inventory.size()-1,new_item_stack)
			else:
				break
	elif remaining_amount < 0:
		var orignal_size = inventory.size()
		for i in range(orignal_size):
			var slot = orignal_size - (i+1)
			var item = inventory[slot]
			if item.is_similar_to(new_item):
				remaining_amount = item.increase_amount(remaining_amount)
				if item.amount <= 0:
					#will remove directly since removing without looping directly
					#should only rearrange the slots that was checked already
					inventory.remove_at(slot)
					slot_update.emit(self,slot,item)
					#trash_items.append(item)
		#if item.is_similar_to(new_item):
			#fill up item amount to the max
		#	remaining_amount = item.increase_amount(remaining_amount)
	
#	for item in trash_items:
#		inventory.erase(item)
	#if
	#if there any amount left over, then add new items untill the amount is used up
	#(meaning the amount in new item will be ignored/overridden)
	return remaining_amount

#TODO convert to use reource(Item) for items instead of dictionary now that it is known resources 
#are not too hard to save with player state
#TODO just need a way to add metadata. could add it directly or loop a dictionary
#so a new item wont nessary need to be made to add to a stack, just use the pass resorce ref
#and a dictionary of modifcations
#this only issue is that there may already be a metadata in the ref(which is not really an issue)
#so it may not be nessary. also maybe a new item is not too bad since the ref will be remove if it not stored
