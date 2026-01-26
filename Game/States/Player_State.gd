class_name Player_State extends State
#NOTE: this is still depenent on data from savable state
#one the few varibles that depends on it is moved to their deicated
#properties (or a none exportable data is added and hook up), then it can be
#transfered

signal score_changed(id:String, new_value:int)

signal vector_changed(id:String, new_value:Variant)
#emits when the inventory structure changes
#such as items being added, removed, or changed
signal advance_inventory_changed(index:int)
#(should) emits when the amount changes. unlike advance,
#it lacks an object that represents the item state
#since only the amount is importaint.
signal standard_inventory_changed(id:String)

#NOTE: _scores could be added to numbers
#but it be easier to get all scores this way
#score may get merge with numbers if that is not expected to be common
#NOTE: might move data to state and not depend on metadata.
#but keep the functions just incase
##The savable data will be saved here
var _data : Dictionary[String,Variant] = {
	'_scores':{},
	'_vars':{},
	'_numbers':{},
	'_vectors':{}
}

#collection base classes read and modify the collection dictionary 
#in player_state._data._collections. They could modfiy their own version
#and player state could convert to save safe, but most cases the save safe
#format should be good enough to use as is unless it depends heavily on objects9
var fish_log : Fish_Log = Fish_Log.new()

#items will be player owned inventory
#cargo will be specail items owned by the player
#such as trade goods, dynamic items, or gear and will have its own limits
#it probababy store it in a easier to save (do not depend on an object)
#and anything that display it should parse that data into the proper item object
#NOTE: this means the version here should convert all object ref to a dict of its state
#or uid string ref.
#stash (if added) will be a mix of the two or just the latter
#for a protective storage
##an dictionary of iten uid(for linking display info) and quanities of that item
var standard_inventory : Dictionary[String,int]

var advance_inventory : Array[Item]

var advance_inventory_size : int = 100 :
	set(value):
		advance_inventory_size = value
		_data['_numbers'].set('_base_cargo_size',value)
	get:
		#Should use a function that add all the modifiers (when they are added)
		#so like number of magic hands, party memeber slots, transport slots
		return _data['_numbers'].get('_base_cargo_size',advance_inventory_size)

@export var exit_data : Exit_Data = Exit_Data.new()


func has_score(id:String)->bool:
	return _data['_scores'].has(id)

func set_score(id:String, new_score: int)->void:
	var old_score = _data['_scores'].get(id,0)
	if old_score != new_score:
		_data['_scores'].set(id,new_score)
		score_changed.emit(id,new_score)
		value_changed.emit(id+"_score",new_score,old_score)
		print_debug("meow! set score of ", self, old_score, '->', new_score,' ', id)
	
func get_score(id:String)->int:
	return _data['_scores'].get(id,0)

func has_vector(id:String)->bool:
	return _data['_vectors'].has(id)

func get_vector(id:String, type : int = 0, as_int : bool = false)->Variant:
	return array_to_vector(_data['_vectors'].get(id,[]),type, as_int)

func set_vector(id:String, vector:Variant)->void:
	var old_vector : Array = _data['_vectors'].get(id,[])
	var new_vector : Array = vector_to_array(vector)
	_data['_vectors'].set(id,vector_to_array(vector))
	if old_vector != new_vector:
		vector_changed.emit(id,vector)
		
	
		
##index only applies to advance inventory
##TODO: limit amount to max stack size.
##NOTE: this can create half filled stack and might not be desired
##so either checks and fillers are needed or this is reserve for
##cases where checks are done before hand or when the desire approch
##is not wanted.
func set_item(item:Item,index:int = 0)->void:
	if item.item_type as Extended_Item_Type:
		var item_copy : Item = Item.load_item(item.data)
		if advance_inventory.size() > index && index >= 0:
			if item_copy.amount > 0:
				advance_inventory[index] = item_copy
			else:
				advance_inventory.remove_at(index)
		elif item_copy.amount > 0 && advance_inventory.size() == index:
			advance_inventory.append(item_copy)
		else:
			print_debug('Index for set_item is out of bounds')
			return
		advance_inventory_changed.emit(index)
		return
	else:
		standard_inventory.set(item.type_uid,item.amount)
		standard_inventory_changed.emit(item.type_uid)
#Note: item pass amount will be changed based on what is taken from it
#so it will have an amount of 0 unless not all of the item was used up
#so it may be better to pass a dupicate of the item if the item amount need
#to stay fixed (aka was not created per task but pulled from a tres or export)
#NOTE: current inventory dose not allow empty slots
#inventory gui can sort it if needed (remap the index)
func add_item(new_item:Item)->void:
	if new_item == null:
		return
	var item_type : Item_Type = new_item.item_type
	if item_type == null:
		return
	if item_type as Extended_Item_Type:
		var remaining_amount : int = new_item.amount
		if remaining_amount > 0:
			for item_slot in range(advance_inventory.size()):
				var item : Item = advance_inventory.get(item_slot)
				#item.load_from_dict(item_data)
				if item.is_similar_to(new_item):
					remaining_amount = item.increase_amount(remaining_amount)
					#item_data.assign(item.convert_to_dict())
					#inventory_modified = true
					#advance_inventory_changed.emit(item_slot)
					#slot_update.emit(self,0,item)
					print_debug('MEOW1 remaining: ', item.amount,' ', advance_inventory.get(item_slot).amount)
			for new_slot in range(advance_inventory_size-advance_inventory.size()):
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
					advance_inventory.append(new_item_stack)
					#advance_inventory.append(new_item_stack.convert_to_dict())
					#inventory.append(new_item_stack)
					#inventory_modified = true
					advance_inventory_changed.emit(advance_inventory.size()-1)
					#slot_update.emit(self,inventory.size()-1,new_item_stack)
					print_debug('MEOW2 amount: ', new_item_stack.amount,' ',advance_inventory.get(advance_inventory.size()-1).amount)
				else:
					break
		elif remaining_amount < 0:
			var orignal_size = advance_inventory.size()
			for i in range(orignal_size):
				var slot = orignal_size - (i+1)
				var item = advance_inventory.get(slot)
				#var item = null
				#if item_data:
				#	item = Item.load_item(item_data)
					#item.load_from_dict(item_data)
				if item.is_similar_to(new_item):
					remaining_amount = item.increase_amount(remaining_amount)
					if item.amount <= 0:
						advance_inventory.remove_at(slot)
						#inventory_modified = true
						#using null to state the item was removed
						#might not need to know what was removed
						#but if needed, could pass additional parameter
						#also may be ideal to pass an object/array
						#that holds extra info
						advance_inventory_changed.emit(slot)
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
	else:
		#would need to store the non object ref to make saving/loading easier
		var old_amount : int = standard_inventory.get(new_item.type_uid,0)
		var new_amount : int = clamp(old_amount + new_item.amount,0,item_type.max_stack_size)
		new_item.amount -= new_amount
		#TODO: Decided if the path should be stored instead of id
		#id may cause issues if change(should not normally) also may
		#be easier to track down the item type with a path
		#the issue with paths is that it could change
		#so having something that states where it is located
		#would help
		standard_inventory.set(new_item.type_uid,new_amount)
		if old_amount != new_amount:
			standard_inventory_changed.emit(new_item.type_uid)
		#NOTE: decide if it should return a value representing
		#what is left over
	#TODO: check item is unique to see if it is stored as a 
	#stardard(false) item or advance(true)
	#make sure that item has an amount, else make sure to add amount as a parameter
	#if advance, make sure to convert to a dictionary that do not hold any ref to object.
	pass

	

func _reset_state() -> void:
	_data.clear()
	_data['_scores']={}
	_data['_vars']={}
	_data['_numbers']={}
	_data['_vectors']={}
	
	fish_log._data.clear()
	
	exit_data.data.clear()
	standard_inventory.clear()
	advance_inventory.clear()
	
func get_save_data()->Dictionary[String,Variant]:
	saving.emit()
	var save_data : Dictionary[String,Variant] = _data
	save_data.set('exit_data',exit_data.data)
	save_data.set('standard_inventory',standard_inventory)
	var temp_adv_inv : Array[Dictionary]
	for item in advance_inventory:
		if item:
			temp_adv_inv.append(item.data)
		else:
			temp_adv_inv.append({} as Dictionary[String,Variant])
	save_data.set('advance_inventory',temp_adv_inv)
	
	save_data.set('data',get_metadata())
	save_data.set('_fish_log', fish_log._data)
	
	return save_data
	

#and load will load the pass data (if changed) and then notify
#all that it is ready(aka loaded)
func load_data(new_data:Dictionary[String,Variant]={})->void:
	_data = new_data
	exit_data.data = new_data.get('exit_data',exit_data.data)
	standard_inventory = new_data.get('standard_inventory', standard_inventory)
	var temp_adv_inv : Array[Dictionary] = new_data.get('advance_inventory', [] as Array[Dictionary])
	for item_data in temp_adv_inv:
		if item_data.is_empty():
			advance_inventory.append(null)
		advance_inventory.append(Item.load_item(item_data))
	#advance_inventory = new_data.get('advance_inventory', advance_inventory)
	
	set_metadata(new_data.get('data', get_metadata()))
	#data = new_data.get('data', data)
	
	fish_log._data = _data.get('_fish_log',fish_log._data)
	
	loaded.emit()
	
	advance_inventory_changed.emit(-1)
	standard_inventory_changed.emit('')
