@tool
class_name Item_Type extends Resource
enum ITEM_FLAGS {
	NONE = 0,
	CONSUMABLE = 1 << 0, #if the item is comsumed on use (reduce amount)
	USE_ON_PICKUP = 1 << 1, #if item will be used when gain
	DROPABLE = 1 << 2, #if item can be removed and drop in the world
	SELLABLE = 1 << 3, 
	DESTROYABLE = 1 << 4, #if item can be removed 
	}
@export_subgroup("Flags")
@export_flags(
	'Consumable', 'Use on pickup', 'Dropable', 'Sellable', 'Destroyable'
) 
var item_flags:int = (
	ITEM_FLAGS.DROPABLE | ITEM_FLAGS.SELLABLE | ITEM_FLAGS.DESTROYABLE | ITEM_FLAGS.CONSUMABLE
)
@export_subgroup("Info")
@export var display_name : String = "Item"
@export var discription : String = "This is an item"
@export var tooltip : String = "tooltip of item"
@export var icon : Texture

@export_file("*.tscn") var item_entity : String

@export_subgroup("Actions")
#NOTE: Should have a targeting option. 
#actions could add filters and notify if invaild so the action could check for
#targets in the action data as long as the triggering node/system adds them
#else this would add something that can be used to fetch vaild targets
#action could (but probably shouldn't(maybe?)) acess the world and get targets that way
@export var on_use_action : Base_Action
@export var on_place_action : Base_Action
