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

#NOTE get_savable_inventory and load_inventory are experimental way
#of getting path free objects, but would be slower to save.
#NOTE: of there more than one item base(like weapons), then items will
#need an additional type base vairble to use that instead of item
#may need to be item group or something
#NOTE:may be ideal to use one item base. most of the weapon data will be static
#which be in the item type. things like duriblity could be part of the item proprties
#or as a meta element
#TODO: test this and see if it is ideal
func get_savable_inventory()->Array[Dictionary]:
	var return_data:Array[Dictionary] = []
	for item in inventory:
		var item_data : Dictionary = {}
		for property in item.get_property_list():
			if property.name in item:
				item_data[property.name] = item[property.name]
		for meta_key in item.get_meta_keys():
			item_data["_meta"] = {}
			item_data["_meta"][meta_key] = item.get_meta(meta_key)
		return_data.append(item_data)
	return return_data
func load_inventory(data:Array[Dictionary]) ->void:
	inventory.clear()
	for item in data:
		var new_item = Item.new() 
		for property in item:
			if property == "_meta":
				for meta_key in data[property]:
					new_item.set_meta(meta_key,data[property][meta_key])
			elif property in new_item:
				new_item[property] = data[property]
			pass
		inventory.append(new_item)

func add_to_inventory(new_item:Item, amount : int = 1) -> int:
	var remaining_amount : int = amount
	var trash_items : Array[Item]
	if remaining_amount > 0:
		for item in inventory:
			if item.is_similar_to(new_item):
				remaining_amount = item.increase_amount(remaining_amount)
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
					inventory.remove_at(slot)
					slot_update.emit(self,slot,item)
	return remaining_amount
