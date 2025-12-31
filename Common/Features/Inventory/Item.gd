##This is the item struct. It holds dynamic data about an item
##such as amount or metadata modifcation.
##Static info like name and discription will be held in the Item_Data
class_name Item extends Resource

#NOTE: signals might not be used here, but that depends since this dose act as the
#item state so it may be best to declare signals as long as they can be correctly
#emitted
signal amount_depleted()
#signal amount_overflow(excess:int)
#TODO: try the static approch that just treats an item stack as a dictionary
#also inventory node would be a componet that will have an resource, array, or dictionary
#of owned items
#NOTE: maybe the item type should have this since it is a fixed value 
#DEPRECATED moved to item type
static var max_stack_size : int = 99 #note, this can not be override in export. need to override the scrip

#ResourceLoader.get_resource_uid(path)
#@export var type : Item_Type = Item_Type.new():

#NOTE: most items will have their type set in code. Most things 
#that give items would expect the item_type to be exported
#since that the static data
@export var type_uid : int = -1

#NOTE: may use this instead of dictionaries.
#just need to keep the old static functions(maybe comment out) just incase 
#dictinary end up being better. 
#NOTE: if use this, can cast to child types to get access to additional var
#like durabulity or quality. the base item will share common item function and varibles
@export var amount:int = 1

func set_type(new_type:Item_Type) -> void:
	if new_type:
		type_uid = ResourceLoader.get_resource_uid(new_type.resource_path)
	else:
		type_uid = -1
func get_type() -> Item_Type:
	if ResourceUID.has_id(type_uid):
		return load(ResourceUID.get_id_path(type_uid))
	else:
		print_debug("WARNING: Returning new Item_Type for Item")
		return Item_Type.new()
#@export var display_name : String = "Item"
#@export var discription : String = "This is an item"
#@export var tooltip : String = "tooltip of item"
#@export var icon : Texture
#the object to spawn if item can be drop or spawn in world. most likly will be a use a share item entity
#but that may not always be wanted(also a meta tag could override this
#@export_file("*.tscn") var item_entity : String


#NOTE: metadata might not be needed since it may exist for objects? so using the built
#in may be better
#var metadata := {}

#this check if two items are similar (meaning if they can stack)
#this could be a lot of checks if the item have a lot of data
#and may be better with a get type or get class override, but require more work
#to make sure the types are correctly set


#NOTE: should call super and use it return value to see if the base values are same
#Note: inventory handler should not have this since it ment to be overriden
##this check if the exported values are the same so that other items types
##can add their own checks(and should else diffrent items may stack)
func is_same_item(other_item:Item)->bool:
	#may be able to compare uid instead so load is not used
	#return type_uid == other_item.type_uid
	return get_type() == other_item.get_type()

#This may be kept in the inventory handler as a static function
func is_similar_to(other_item:Item)->bool:
	if other_item == null: 
		#print_debug("item is null")
		return false
	if (is_same_item(other_item)):
		if get_meta_list().is_empty() and other_item.get_meta_list().is_empty():
			return true
		elif get_meta_list().size() != other_item.get_meta_list().size():
			#print_debug("metadata sizes are diffrent ", get_meta_list(), ' ', other_item.get_meta_list())
			return false
		else:
			for key in get_meta_list():
					#NOTE: resources might break this so it may be best to
					#either not use resources/object or stress test it with 
					#a resource case
				var self_value = get_meta(key)
				var other_value = other_item.get_meta(key)
				if typeof(self_value) == typeof(other_value):
					if get_meta(key) != other_item.get_meta(key):
						#print_debug(str(key) + " = diffrent key")
						return false
				else:
					#print_debug(str(key) + " = diffrent value: " +str(self_value)+" vs "+str(other_value))
					return false
			return true
	#print_debug("is not same item")
	return false

##this check if the item is exactly the same
##for usages dealing with quests. Thought it best to check the amount
##instead, but this will be here as another option where both items need to be ther same
func is_equal_to(other_item:Item) -> bool :
	if is_similar_to(other_item):
		if amount == other_item.amount:
			return true
	return false
# this is currently in use. 
func increase_amount(new_amount:int) -> int:
	var total_amount : int = amount + new_amount
	var remaining_amount : int = new_amount
	var item_type = get_type()
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

func convert_to_dict()->Dictionary[String,Variant]:
	var data : Dictionary[String,Variant] = {
		'amount':amount,
		'type_uid':type_uid
	}
	for meta in get_meta_list():
		data['meta_'+meta] = get_meta(meta)
	return data 
	
func load_from_dict(data:Dictionary[String,Variant]):
	amount = data.get('amount',amount)
	type_uid = data.get('type_uid',type_uid)
	for meta_id:String in data.keys():
		if meta_id.begins_with('meta_'):
			var meta : String = meta_id.trim_prefix('meta_')
			set_meta(meta, data[meta_id])

func _init(item_type: Item_Type = null) -> void:
	set_type(item_type)
