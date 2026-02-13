class_name Player_State extends State
#NOTE: this is still depenent on data from savable state
#one the few varibles that depends on it is moved to their deicated
#properties (or a none exportable data is added and hook up), then it can be
#transfered

signal score_changed(id:String, new_value:int)
signal number_changed(id:String, new_value:Variant)
signal var_changed(id:String, new_value:String)

signal vector_changed(id:String, new_value:Variant)


##the exit info used on new games (or when the state is reset)
@export var default_exit_data : Exit_Data = Exit_Data.new()
##A list of items to add to the player inventories. 
##NOTE: depending on the item_type and inventory, latter 
##entries may override similar entries
@export var default_items : Array[Item]



##the current exit data in use
var exit_data : Exit_Data = Exit_Data.new()

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
var standard_inventory : Inventory = Inventory.new()

#var advance_inventory : Array[Item]
var advance_inventory : Advance_Inventory = Advance_Inventory.new()

var player_debug_message : String

static func get_default_instance()-> State:
	return load('uid://c67c2fehtuhni')

func has_score(id:String)->bool:
	return _data['_scores'].has(id)

func set_score(id:String, new_score: int)->void:
	var old_score = _data['_scores'].get(id,0)
	if old_score != new_score:
		_data['_scores'].set(id,new_score)
		_on_score_changed(id,new_score,old_score)
		score_changed.emit(id,new_score)
		value_changed.emit("_score",new_score,old_score,[id])
		#print_debug("meow! set score of ", self, old_score, '->', new_score,' ', id)
	
func get_score(id:String)->int:
	return _data['_scores'].get(id,0)
	
func _on_score_changed(id:String, new_score: int, old_score:int)->void:
	pass 

func has_number(id:String)->bool:
	return _data['_numbers'].has(id)

func set_number(id:String, new_number: Variant)->void:
	#TODO: make sure new number is a int or a float and 
	#handle cases when either is false
	if !is_number(new_number):
		push_error('new_number is not a number. Pass it as a int or float')
		return
	var old_number = _data['_numbers'].get(id,0)
	if old_number != new_number:
		_data['_numbers'].set(id,new_number)
		_on_number_changed(id,new_number,old_number)
		number_changed.emit(id,new_number)
		value_changed.emit("_numbers",new_number,old_number,[id])

func get_number(id:String, default:Variant=0)->Variant:
	return _data['_numbers'].get(id,default)
	
func _on_number_changed(id:String, new_number: Variant, old_number:Variant):
	if id == '_base_cargo_size' || id == 'magic_hands':
		update_advance_inventory_size()
	pass

func has_var(id:String)->bool:
	return _data['_vars'].has(id)

func set_var(id:String, new_var: String)->void:
	var old_var = _data['_vars'].get(id,'')
	if old_var != new_var:
		_data['_vars'].set(id,new_var)
		_on_var_changed(id, new_var, old_var)
		var_changed.emit(id,new_var)
		value_changed.emit("_vars",new_var,old_var,[id])

func get_var(id:String,default:String='')->String:
	return _data['_vars'].get(id,default)
	
func _on_var_changed(id:String, new_var: String, old_var:String)->void:
	pass
	
func has_vector(id:String)->bool:
	return _data['_vectors'].has(id)

func get_vector(id:String, type : int = 0, as_int : bool = false)->Variant:
	return array_to_vector(_data['_vectors'].get(id,[]),type, as_int)

func set_vector(id:String, vector:Variant)->void:
	var old_vector : Array = _data['_vectors'].get(id,[])
	var new_vector : Array = vector_to_array(vector)
	_data['_vectors'].set(id,vector_to_array(vector))
	if old_vector != new_vector:
		_on_vector_changed(id,vector,new_vector,old_vector)
		vector_changed.emit(id,vector)
		value_changed.emit("_vectors",new_vector,old_vector,[id])

func _on_vector_changed(id:String,vector_variant:Variant, new_vector:Array,old_vector:Array)->void:
	pass
	

func update_advance_inventory_size()->void:
	advance_inventory.max_size = (
		get_number('_base_cargo_size',advance_inventory.max_size) +
		get_number('magic_hands',0)
	)
	

#NOTE: may create an object for each inventory type for reusability
#and to reduce clutter in the player state
func set_item(item:Item,index:int = 0)->void:
	if item.item_type as Extended_Item_Type:
		advance_inventory.set_item(item,index)
	else:
		standard_inventory.set_amount(item.type, item.amount)

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
		advance_inventory.add_item(new_item)
	else:
		standard_inventory.increase_amount(str(new_item.type_uid),new_item.amount)
		
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
	
	exit_data.data = default_exit_data.data.duplicate()
	
	standard_inventory.clear()
	advance_inventory.clear()
	for item in default_items:
		if item == null:
			continue
		if (item.item_type as Extended_Item_Type):
			advance_inventory.set_item(item)
		else:
			standard_inventory.set_amount(str(item.type_uid),item.amount)
	
func get_save_data()->Dictionary[String,Variant]:
	saving.emit()
	var save_data : Dictionary[String,Variant] = _data
	save_data.set('exit_data',exit_data.data)
	save_data.set('standard_inventory',standard_inventory.items_data)
	var temp_adv_inv : Array[Dictionary] = advance_inventory.get_items_data()

	save_data.set('advance_inventory',temp_adv_inv)
	
	save_data.set('data',get_metadata())
	save_data.set('_fish_log', fish_log._data)
	
	return save_data
	

#and load will load the pass data (if changed) and then notify
#all that it is ready(aka loaded)
#TODO: make sure a new game case is handled so the defaults are correctly applied
func load_data(new_data:Dictionary[String,Variant]={})->void:
	_data = new_data
	exit_data.data = new_data.get('exit_data',exit_data.data)
	standard_inventory.items_data = new_data.get('standard_inventory', standard_inventory.items_data)
	var temp_adv_inv : Array[Dictionary] = new_data.get('advance_inventory', [] as Array[Dictionary])
	
	#should update the size before loading the items just incase
	#the latter ever needs to depend on size
	update_advance_inventory_size()
	advance_inventory.load_items(temp_adv_inv)
	
	set_metadata(new_data.get('data', get_metadata()))
	#data = new_data.get('data', data)
	
	fish_log._data = _data.get('_fish_log',fish_log._data)
	
	loaded.emit()
	
	#Todo: decide on how to handled inventory change on load
	#below could work, but a bit of a brute solution. a dedicated load
	#may be better, but require all listenerns to handle a on load case.
	advance_inventory.changed.emit(-1)
	standard_inventory.changed.emit('',-1)
