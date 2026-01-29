##This is for item types that represents catchable fish
##it is used more as a filter and a helper class in setting the resource data.
class_name Fish_Item_Type extends Extended_Item_Type

#Size is a modifier of the fish weight
#and should be greater than 0
@export var min_size : float = 0.5
@export var max_size : float = 1.5

#may be flags(int bitflgs) or tags(array of strings) such as fresh water,
#sea water, (void, sky, sand, mud, ect). Used for display reason or building tables
#from data
@export var habitat : int = 1
#TODO: need other flag/tags for which ways it can be catched. pounce fishing
#do not need it (unless lures are added), but advance fishing would if it is added
#later (which also mean fish being filtered out for pounce fishing)
#NOTE:TODO: make a system that generate tables from the fish data at runtime
#could use the tables to declare types and then repopulate them at start or on load
#may need to extend weighted groups to have a filter and handle array of tables

#NOTE: rare fish stuff is optinal way to compact declartion of fish
#and might not be used if manually declaring them is deem more ideal
#and use rarity instead for their stats
@export var rarity : int = 1

#NOTE: may add on use like actions that fish will make use of
#could be used to fake a catch action by making a catch item (like junk)
#and provide images for displaying...but need to flag the action data(or item) to
#ignore adding the item to inventory. could also add it to the item type base
#and use on_pickup and a flag that state it should be used up when pick up
#NOTE: may be better to try to have the system use actions instead of using items
#like that and only handle it that way for specail cases
@export var on_catch_action : Base_Action
