class_name Inventory extends RefCounted

signal changed(type_id:String, amount:int)

#NOTE: this dupulicate Item logic to not make item instances
#needed (well could not cache the item data, but would make
#large inventories slower to save and the data simple enought)

##This is the items in the inventory. It is marked private to deter
##ref changes and other unwanted changes.
var items_data : Dictionary[String,int]
#reserver for caching items made from get_item
var _items_instances : Dictionary[String,Item]

func load_item_type(type_id)->Item_Type:
	if type_id.is_valid_int():
		var type_uid : int = type_id.to_int()
		if ResourceUID.has_id(type_uid):
			return load(ResourceUID.get_id_path(type_uid))
	return load(type_id)

#gets an item object which acts as getting both the
#item type object and amount. NOTE: the item object signals
#would be independent. 
#NOTE: it may be best not to use this onless the item is being handled
#and in such cases, the item instances should be removed one finished
func get_item(type_id:String)->Item:
	var item: Item = _items_instances.get(type_id)
	if item:
		return item
	var item_type : Item_Type = load_item_type(type_id)
	#if type_id.is_valid_int():
	#	var type_uid : int = type_id.to_int()
	#	if ResourceUID.has_id(type_uid):
	#		item_type = load(ResourceUID.get_id_path(type_uid))
	#else:
	#	item_type = load(type_id)
	if item_type:
		item = Item.new(item_type) 
		item.amount = items_data.get(type_id,0)
		_items_instances.set(type_id,item)
		item.amount_changed.connect(on_item_amount_changed)
	return item

#this only remove the instance and should be called if using the item
#to listen to signal changes
func uncache_item(type_id:String)->void:
	var item : Item = _items_instances.get(type_id)
	if item:
		item.amount_changed.disconnect(on_item_amount_changed)
		_items_instances.erase(type_id)
	
func get_amount(type_id:String)->int:
	return items_data.get(type_id,0)

func size()->int:
	return items_data.size()

func loaded_instance_size()->int:
	return _items_instances.size()

#NOTE: this may need its own signal to notify since this will
#break any item instances being listen too. it here for load game
#where everything should be reset.
func clear()->void:
	items_data.clear()
	_items_instances.clear()
	
func set_amount(type_id:String,amount:int=0)->int:
	var remainer: int = 0
	var item: Item = _items_instances.get(type_id)
	if item:
		remainer = item.set_amount(amount)
		return remainer
	else:
		var item_type : Item_Type = load_item_type(type_id)
		if amount < 0:
			items_data.set(type_id,0)
			changed.emit(type_id, 0)
			return amount
		if amount > item_type.max_stack_size and item_type:
			items_data.set(type_id,item_type.max_stack_size)
			changed.emit(type_id, item_type.max_stack_size)
			return amount - item_type.max_stack_size
	items_data.set(type_id,amount)
	changed.emit(type_id, amount)
	return remainer
	
func increase_amount(type_id:String,new_amount:int) -> int:
	var item: Item = _items_instances.get(type_id)
	if item:
		return item.increase_amount(new_amount)
	var amount : int = get_amount(type_id)
	var total_amount : int = amount + new_amount
	var remaining_amount : int = new_amount
	var item_type : Item_Type = load_item_type(type_id)
	if new_amount == 0:
		return 0
	elif new_amount > 0:
		remaining_amount = max(total_amount-item_type.max_stack_size,0)
		amount = min(total_amount, item_type.max_stack_size)
	else:
		remaining_amount = min(total_amount,0)
		amount = max(total_amount, 0)
	items_data.set(type_id,amount)
	changed.emit(type_id, amount)
	return remaining_amount

#relay the item change signal here to keep both instances sync
func on_item_amount_changed(item:Item)->void:
	items_data.set(item.type_uid, item.amount)
	changed.emit(item.type_uid, item.amount)
