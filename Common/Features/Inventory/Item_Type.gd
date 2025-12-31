class_name Item_Type extends Resource

@export var display_name : String = "Item"
@export var discription : String = "This is an item"
@export var tooltip : String = "tooltip of item"
@export var icon : Texture

##a way to override this item type stack size
##NOTE: Might not be applied to items in general. Mostly to let
##inventories knows about the limits. Items as template to give 
##the the player may have a higher amount
@export var max_stack_size : int = 99
##states if this item can have metadata or not.
##useful to filter if static items and dynamic items are handled by two system
##(defaulting to true since current system uses unique. #TODO: default to false later
@export var is_unique : bool = true
#the object to spawn if item can be drop or spawn in world. most likly will be a use a share item entity
#but that may not always be wanted(also a meta tag could override this
@export_file("*.tscn") var item_entity : String
