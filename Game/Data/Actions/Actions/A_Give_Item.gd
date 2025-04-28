class_name A_Give_Item extends Base_Action

##the item info needed to create or add an item to give. 
##NOTE May use only one item base to keep things simple. can expand on it as needed
@export var item : Item
@export var item_type : Item_Type
##seems the metadata feild do not appear on the item
##so this is to manually set it. NOTE: should use an action to do this or
##use item varibles instead of metadata. so this may be removed later
@export var item_meta : Dictionary

#TODO: deicide on a naming system for targets and maybe use an enum to identify it
#NOTE: if handling dynamic amount of ref, an enum wont be enough, an id(index) would
#be needed to identify an object in an array
##will give the item to the owner. Since the owner is the one that trigger the event
##they may be the one that get the item. the targer is the one who being interacted with
##or hit
@export var give_to_owner : bool = true
#NOTE: below is old. target and owner are vaibles in data. just need to pick the source
##since this can not take a node as a ref, it would need to find a ref in the
##data. So a fetch player pawn would be needed or the node that owns this needs
##to pass a node ref. It could also ref the owning node
@export var target_id : String = "target"
##this is for a future idea where targets(or other nodes) are stored in an array
##where id alone is not enough info. 
@export var target_index : int = 0

func run(data:Action_State = null) -> bool:
	#NOTE: interactive component the interactor is the owner.
	#so giving to owner should be the default unless the action is targeting
	#the one being interactive with
	var target : Node
	var inventory : Inventory
	if data == null:
		print_debug("no vaild data")
		return false
	if give_to_owner:
		print_debug("giving to owner")
		target = data.owner
	else:
		print_debug("giving to target")
		target = data.target
	if target == null: 
		print_debug("target is null")
		return false
	if (target as Character2D):
		print_debug("target is character")
		inventory = target.get_inventory()
	else:
		print_debug("target is not character")
		#NOTE: this should not be called outside of protyoping.
		#should have a an inventory holder class to check for and grab the active inventory
		for child in target.get_children():
			if child is Inventory:
				inventory = child
				break
	if inventory == null:
		print_debug("inventory is null")
		return false
	
	#var new_item = item.duplicate()
	#new_item.set_type(item_type)
	var new_item = Item.new(item_type)
	if item_meta.is_empty():
		inventory.add_to_inventory(new_item,1)
	else:
		#dupucate the item and then add the meta to prevent any modification of the
		#assign item
		for key in item_meta:
			new_item.set_meta(key,item_meta[key])
		inventory.add_to_inventory(new_item,1)
	print_debug("item should have been added?")
	return true
	
	#return super(data)
