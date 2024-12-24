##This is the item struct. It holds dynamic data about an item
##such as amount or metadata modifcation.
##Static info like name and discription will be held in the Item_Data
class_name Item extends Resource

signal amount_depleted()
#signal amount_overflow(excess:int)
#TODO: try the static approch that just treats an item stack as a dictionary
#also inventory node would be a componet that will have an resource, array, or dictionary
#of owned items
static var max_stack_size : int = 99 #note, this can not be override in export. need to override the scrip










@export var type : Item_Type = Item_Type.new()
#@export var display_name : String = "Item"
#@export var discription : String = "This is an item"
#@export var tooltip : String = "tooltip of item"
#@export var icon : Texture
#the object to spawn if item can be drop or spawn in world. most likly will be a use a share item entity
#but that may not always be wanted(also a meta tag could override this
#@export_file("*.tscn") var item_entity : String

#NOTE: may use this instead of dictionaries.
#just need to keep the old static functions(maybe comment out) just incase 
#dictinary end up being better. 
#NOTE: if use this, can cast to child types to get access to additional var
#like durabulity or quality. the base item will share common item function and varibles
var amount:int = 1
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
	#print_debug("name: "+str(display_name) + " vs " + str(other_item.display_name))
	#print_debug("discription: "+str(discription) + " vs " + str(other_item.discription))
	#print_debug("tooltip: "+str(tooltip) + " vs " + str(other_item.tooltip))
	#print_debug("icon: "+str(icon) + " vs " + str(other_item.icon))
	
	#testing uid comparison:
	#print_debug("icon: "+str(icon.get_rid()) + " vs " + str(other_item.icon.get_rid()))
	#var test:Resource
	#test.get_rid()
	return type == other_item.type
	
	#if (display_name == other_item.display_name and
	#	discription == other_item.discription and 
	#	tooltip == other_item.tooltip and 
	#	icon.get_rid() == other_item.icon.get_rid()
		#NOTE: icon, being a resource, may be impoperly ref
		#which will make the item be diffrent. need a better way to identify it
		#or not compare icon.
		#in short, rid check would be nessary when storing resource. 
		#THIS means metadata check need to add a way to check if value
		#is a resource and run the rid check instead of ==
	#):
	#	return true
	return false

#This may be kept in the inventory handler as a static function
func is_similar_to(other_item:Item)->bool:
	if other_item == null: 
		#print_debug("item is null")
		return false
	if (is_same_item(other_item)):
		if get_meta_list().is_empty() and other_item.get_meta_list().is_empty():
			return true
		elif get_meta_list().size() != other_item.get_meta_list().size():
			#print_debug("metadata sizes are diffrent")
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
	
func increase_amount(new_amount:int) -> int:
	var total_amount : int = amount + new_amount
	var remaining_amount : int = new_amount
	if new_amount == 0:
		return 0
	elif new_amount > 0:
		remaining_amount = max(total_amount-max_stack_size,0)
		amount = min(total_amount, max_stack_size)
		#if amount > max_stack_size:
			#amount_overflow.emit(remaining_amount)
	else:
		remaining_amount = min(total_amount,0)
		amount = max(total_amount, 0)
		if amount <= 0:
			amount_depleted.emit()
			
	#TODO check if this works
	return remaining_amount
	
