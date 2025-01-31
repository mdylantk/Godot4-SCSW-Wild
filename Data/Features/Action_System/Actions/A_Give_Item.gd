class_name A_Give_Item extends Base_Action

##the item info needed to create or add an item to give
@export var item : Item

#TODO: deicide on a naming system for targets and maybe use an enum to identify it
#NOTE: if handling dynamic amount of ref, an enum wont be enough, an id(index) would
#be needed to identify an object in an array
##since this can not take a node as a ref, it would need to find a ref in the
##data. So a fetch player pawn would be needed or the node that owns this needs
##to pass a node ref. It could also ref the owning node
@export var target_id : String = "target"
##this is for a future idea where targets(or other nodes) are stored in an array
##where id alone is not enough info. 
@export var target_index : int = 0

func run(data:Action_Data = null) -> bool:
	print_debug("not yet added, so nothing happen")
	#TODO: see if target exist and then check if it have an inventory
	#then add the item
	#NOTE: decide if this system should be simple like that or should have
	#a dedicated handler
	return super(data)
