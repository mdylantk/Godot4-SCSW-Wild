##This is the item struct. It holds dynamic data about an item
##such as amount or metadata modifcation.
##Static info like name and discription will be held in the Item_Data
class_name Item extends Resource


signal amount_depleted()
#decide if a removed/deleted/null/depleted is needed
#item may be pass mostly by functions and signals, so there
#might not be a needed. amount depleted may still have uses though
signal amount_changed(item:Item)
signal type_changed(item:Item)
##NOTE: key as an empty string should be treated
##as the whole metadata was changed.
##TODO: decided if empty string should not be vaild
##metadata key.
signal metadata_changed(item:Item, key:String)
#signal amount_overflow(excess:int)
#TODO: try the static approch that just treats an item stack as a dictionary
#also inventory node would be a componet that will have an resource, array, or dictionary
#of owned items
#NOTE: maybe the item type should have this since it is a fixed value 
#DEPRECATED moved to item type
#static var max_stack_size : int = 99 #note, this can not be override in export. need to override the scrip

#ResourceLoader.get_resource_uid(path)
#@export var type : Item_Type = Item_Type.new():

#TODO: Since we are now converting savable info into a dictionary for the
#state, there no need to use the old get and set type.
#since we wont be saving this object directly
##item_type need to be an Item_Type with a uid
##in other words, the item needs a declared .tres file
##NOTE: Not sure if a uid should be generated for item types
##created in the editor. Item types are meant to be reusable item info
@export var item_type : Item_Type :
	set(value):
		var old_value: Item_Type = item_type
		if old_value == value:
			return
		item_type = value
		if item_type:
			type_uid = ResourceLoader.get_resource_uid(item_type.resource_path)
			data.set('type_uid', type_uid)
		else:
			type_uid = -1
			data.set('type_uid', -1)
		type_changed.emit(self)
	#get:
	#	if item_type == null:
	#		if ResourceUID.has_id(type_uid):
	#			item_type = load(ResourceUID.get_id_path(type_uid))
	#	return item_type
#NOTE: may use this instead of dictionaries.
#just need to keep the old static functions(maybe comment out) just incase 
#dictinary end up being better. 
#NOTE: if use this, can cast to child types to get access to additional var
#like durabulity or quality. the base item will share common item function and varibles
@export var amount:int = 1 :
	set(value):
		var old_value: int = amount
		if old_value == value:
			return
		data.set('amount', value)
		amount = value
		amount_changed.emit(self)
	get:
		return data.get('amount', amount)
#NOTE: will use this or other array/dictionaries for
#extra optional data and perhaps even store child data
#instead so item types can be switch with little impact except
#(NOTE: switching item type with diffrent stack size could be an issue
#and such cases would need to be handle if item_type switching become common)
#NOTE: should store ref as uid or uid plus data like dictionary
#may need a var to hold the loaded values and a system to load and update it
#such cases also could use an array of a uid number and a data dictionary
#or can be only an array if the structure is finalized
@export var metadata : Dictionary[String,Variant]:
	set(value):
		#NOTE: this metadata is for editor setting
		#should provide ways to set and get metadata
		#and manually handle cases that modify it in bulk
		#and make sure to emit the signal to notify of changes
		metadata = value
		data.set('metadata',metadata)
		#calling this just incase it is changed, but will be called anytime
		#it get set. it should not happen often
		metadata_changed.emit(self,'')
	get:
		return data.get('metadata',{} as Dictionary[String,Variant])
#the main data of the item. the items should act as an interface to 
#this data since the data may exist elsewhere and items are normally
#short lived objects used to catch item resources while needed
var data : Dictionary[String,Variant] :
	set(value):
		data = value
		if ResourceUID.has_id(type_uid):
			item_type = load(ResourceUID.get_id_path(type_uid))
#this may be removed since it will exist in metadata. 
#it may stay for a bit with a getter
#since a few functions depends on this
var type_uid : int = -1 : 
	get:
		return data.get('type_uid',type_uid)
	#NOTE: items created in editor do not have the setters called
	#so need to have a check to make sure the uid is set if there is a item_type
	#but uid is -1
	#get():
	#	if type_uid == -1 and item_type:
	#		type_uid = ResourceLoader.get_resource_uid(item_type.resource_path)
	#	return type_uid

#TODO: Decide if _init should take only data
#and provide a static function to populate it
#since data may be used to create it if not 
#created by a resource(item_type is needed to create
#an item so that is needed in at least one way)
##returns a new item base on the Item_Type
static func create_item(type:Item_Type)->Item:
	return Item.new(type)
	#new_item.item_type = type

##returns a new item from the provided data
static func load_item(new_data:Dictionary[String,Variant]):
	return Item.new(null, new_data)
	
func is_same_item(other_item:Item)->bool:
	#may be able to compare uid instead so load is not used
	#return type_uid == other_item.type_uid
	return item_type == other_item.item_type

#This may be kept in the inventory handler as a static function
func is_similar_to(other_item:Item)->bool:
	if other_item == null: 
		#print_debug("item is null")
		return false
	if (is_same_item(other_item)):
		if metadata.is_empty() and other_item.metadata.is_empty():
			return true
		elif metadata.size() != other_item.metadata.size():
			#print_debug("metadata sizes are diffrent ", get_meta_list(), ' ', other_item.get_meta_list())
			return false
		else:
			#NOTE: this might work, but should try to figure out
			#a depth limit
			if metadata.recursive_equal(other_item.metadata,10):
				return true
			else:
				return false
	return false

##this check if the item is exactly the same
##for usages dealing with quests. Thought it best to check the amount
##instead, but this will be here as another option where both items need to be ther same
func is_equal_to(other_item:Item) -> bool :
	#if data is kept as is, then could compare the two
	if is_similar_to(other_item):
		if amount == other_item.amount:
			return true
	return false
# this is currently in use. 
func increase_amount(new_amount:int) -> int:
	var total_amount : int = amount + new_amount
	var remaining_amount : int = new_amount
	#print_debug('MEOW: ', amount, '+', new_amount, '=', total_amount )
	#var item_type = get_type()
	if new_amount == 0:
		return 0
	elif new_amount > 0:
		remaining_amount = max(total_amount-item_type.max_stack_size,0)
		amount = min(total_amount, item_type.max_stack_size)
		#if amount > max_stack_size:
			#amount_overflow.emit(remaining_amount)
	else:
		remaining_amount = min(total_amount,0)
		amount = max(total_amount, 0)
		if amount <= 0:
			amount_depleted.emit()
			
	#TODO check if this works
	return remaining_amount

#might not need a get_metadata
#set is to trigger metadata change signal so
#ui can update itself
func set_metadata(key:String,value:Variant)->void:
	metadata.set(key,value)
	metadata_changed.emit(self,key)

#func convert_to_dict()->Dictionary[String,Variant]:
#	return data 
	
#func load_from_dict(new_data:Dictionary[String,Variant]):
#	data = new_data
	#if ResourceUID.has_id(type_uid):
	#	item_type = load(ResourceUID.get_id_path(type_uid))
	#for meta_id:String in data.keys():
	#	if meta_id.begins_with('meta_'):
	#		var meta : String = meta_id.trim_prefix('meta_')
	#		set_meta(meta, data[meta_id])
##Either pass item_type or item data as a dictionary.
##otherwise data will override item_type 
##Item.create_item and Item.load_item are the dedicated way to make a new item
func _init(_item_type: Item_Type = item_type, new_data:Dictionary[String,Variant] = {} ) -> void:
	if new_data.is_empty():
		item_type = _item_type
	else:
		data = new_data
		#load_from_dict(new_data)
