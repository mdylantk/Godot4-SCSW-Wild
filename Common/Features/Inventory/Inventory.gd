#NOTE: changeing from a node to a refcounted, but may rename it to
#advance inventory or cargo or something related to its use
class_name Inventory extends RefCounted

signal changed(slot:int)

##This is the items in the inventory. It is marked private to deter
##ref changes and other unwanted changes.
var _items : Array[Item]

##The current amount of slots (or the max allowed _item size)
##of the inventory
var total_size : int = 100 :
	get:
		if slots_override:
			return slots_override.call(total_size)
		return total_size

##an optional override for caculating the current slots
##but it may be better to manually update slots instead 
##so this is more of a test
var slots_override:Callable #= func(base_slots):return base_slots

func get_item(index:int)->Item:
	return _items.get(index)

func size()->int:
	return _items.size()
	
func clear()->void:
	_items.clear()

##index only applies to advance inventory
##TODO: limit amount to max stack size.
##NOTE: this can create half filled stack and might not be desired
##so either checks and fillers are needed or this is reserve for
##cases where checks are done before hand or when the desire approch
##is not wanted.
func set_item(item:Item,index:int = 0)->void:
	var item_copy : Item = Item.load_item(item.data)
	if _items.size() > index && index >= 0:
		if item_copy.amount > 0:
			_items[index] = item_copy
		else:
			_items.remove_at(index)
	elif item_copy.amount > 0 && _items.size() == index:
		_items.append(item_copy)
	else:
		print_debug('Index for set_item is out of bounds')
		return
	changed.emit(index)
	
func add_item(new_item:Item)->void:
	if new_item == null:
		return
	var item_type : Item_Type = new_item.item_type
	if item_type == null:
		return
	var remaining_amount : int = new_item.amount
	if remaining_amount > 0:
		for item_slot in range(_items.size()):
			var item : Item = _items.get(item_slot)
			#item.load_from_dict(item_data)
			if item.is_similar_to(new_item):
				remaining_amount = item.increase_amount(remaining_amount)
					#item_data.assign(item.convert_to_dict())
					#inventory_modified = true
					#advance_inventory_changed.emit(item_slot)
					#slot_update.emit(self,0,item)
				print_debug('MEOW1 remaining: ', item.amount,' ', _items.get(item_slot).amount)
		for new_slot in range(total_size-_items.size()):
			if remaining_amount > 0:
				var new_item_stack : Item = Item.load_item(new_item.data,true)
				var new_amount = remaining_amount
				if remaining_amount > item_type.max_stack_size:
					new_amount = item_type.max_stack_size
					remaining_amount = remaining_amount - new_item_stack.item_type.max_stack_size
						#advance_inventory_changed.emit(new_slot)
				else:
					new_amount = remaining_amount
					remaining_amount = 0
				new_item_stack.amount = new_amount
				_items.append(new_item_stack)
					#advance_inventory.append(new_item_stack.convert_to_dict())
					#inventory.append(new_item_stack)
					#inventory_modified = true
				changed.emit(_items.size()-1)
					#slot_update.emit(self,inventory.size()-1,new_item_stack)
				print_debug('MEOW2 amount: ', new_item_stack.amount,' ',_items.get(_items.size()-1).amount)
			else:
				break
	elif remaining_amount < 0:
		var orignal_size = _items.size()
		for i in range(orignal_size):
			var slot = orignal_size - (i+1)
			var item = _items.get(slot)
				#var item = null
				#if item_data:
				#	item = Item.load_item(item_data)
					#item.load_from_dict(item_data)
			if item.is_similar_to(new_item):
				remaining_amount = item.increase_amount(remaining_amount)
				if item.amount <= 0:
					_items.remove_at(slot)
						#inventory_modified = true
						#using null to state the item was removed
						#might not need to know what was removed
						#but if needed, could pass additional parameter
						#also may be ideal to pass an object/array
						#that holds extra info
					changed.emit(slot)
						#slot_update.emit(self,slot,item)
					#advance_inventory_changed.emit(slot)
					#else:
					#	item_data.assign(item.convert_to_dict())
		#TODO:make sure this is correct
		#that all cases above will set the remaining amount base on use
		#should be 0 if used up, but positive is some is left over
		#or negative if not enoigh was taken away.
	new_item.amount = remaining_amount
		#if inventory_modified:
		#	advance_inventory_changed.emit()
	print_debug('MEOW3 remaining: ', new_item.amount)

##return an array of dictionary representing the items in a way that can
##be saved without session only ref
func get_items_data()->Array[Dictionary]:
	var items_data : Array[Dictionary]
	for item in _items:
		if item:
			items_data.append(item.data)
		else:
			items_data.append({} as Dictionary[String,Variant])
	return items_data

func load_items(items_data:Array[Dictionary])->void:
	for item_data_index in range(items_data.size()):
		var item_data = items_data.get(item_data_index)
		
		if item_data.is_empty():
			#TODO: decide how to handle invaild cases
			continue
			#items.append(null)
		#NOTE: item.load_item could make an improper item
		#that would not be safe to save (no uid so it wont be loaded
		#except as a Item.new())
		set_item(Item.load_item(item_data),item_data_index)
