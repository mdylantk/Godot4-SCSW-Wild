class_name Item extends Resource

#TODO: try the static approch that just treats an item stack as a dictionary
#also inventory node would be a componet that will have an resource, array, or dictionary
#of owned items
static var max_stack_size : int = 99 #note, this can not be override in export. need to override the scrip

func new_item(amount = 1, meta = {}): 
	var item : Dictionary = {}
	item["type"] = self #since the item created is base off a templace, it should have an instance in
	#the data base. Note: creating a new item resource at runtime is risky and this not design to handle that
	#since that new dynamic source may be lost on load ore change. item data is for dynamic item info
	item["amount"] = amount
	item["meta"] = meta #meta is opional data that could be clear and wont mess up item functionalty
	#print(type.is_similar_item(item, item))
	return item

static func is_item(item : Dictionary):
	if item.has("type") and item.has("amount") and item.has("meta"):
		return true
	else:
		return false

static func get_type(item):
	if item.has("type") :
		#this may be null or not an Item, so more check should be added
		return item["type"]
	return Item #NOTE: change this since it could cause issues

static func get_amount(item:Dictionary):
	if item.has("amount") :
		return item["amount"]
	return 1

static func set_amount(item:Dictionary, amount : int):
	item["amount"] = amount

static func add_amount(item:Dictionary, amount : int):
	var new_amount = get_amount(item)
	var left_over = 0
	var item_type = get_type(item)
	new_amount += amount
	if new_amount <= 0:
		print("nulling item?. dose not seem to be allowed. item seems to be a copy")
		left_over = new_amount
		item.clear() #setting to {} did not work, but this did
		#print(str(item))
	elif(item_type.max_stack_size > 0 and new_amount > item_type.max_stack_size):
		left_over = new_amount - item_type.max_stack_size
		set_amount(item, item_type.max_stack_size)
	else:
		set_amount(item, new_amount)
		left_over = 0
	#return the amount changed. if 0 or less, then not all the amount was used up
	return left_over 

#return true if most of the item properties are the same. the axception is amount
static func is_similar_item(source_item: Dictionary, other_item: Dictionary): 
	#TODO: test this. alot could go wrong. it check in steps to eand as soon as something is false
	if is_item(source_item) and is_item(other_item):
		if source_item.size() == other_item.size():
			for key in source_item.keys():
				if key != "amount":
					if other_item.has(key):
						#no need to loop meta. as long as == works as equal(exact)
						if source_item[key] != other_item[key]:
							return false
					else:
						return false
		else:
			return false
	else:
		return false
	return true
	
@export var display_name : String = "Item"
@export var discription : String = "This is an item"
@export var tooltip : String = "tooltip of item"
@export var icon : Texture
#the object to spawn if item can be drop or spawn in world. most likly will be a use a share item entity
#but that may not always be wanted(also a meta tag could override this
@export_file("*.tscn") var item_entity : String
