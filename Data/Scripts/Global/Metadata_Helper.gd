class_name Metadata_Helper extends Object
#this class is ment to help debug usage of metadata usally for major usage
#It also is ment to be a form of documentry of the types of meta data stored
#Sometimes a node need a flag or a varible, but making many scripts for such
#case seems choatic. Metadata is part of all node and should be faster than
#checking a node varible or functions. In other words metadata is good to 
#to extend existing node at the cost of readability and debuging.
#static function libaries, like this one, could help with debugging
#at the cost of an additional function call. So metadata stored this way
#is best not used for importiant system that need to run often or every tick

##a flag that state if a node is ready for use in cases where a node may take
##a few ticks to process. This is to help with loading screens staying up
##if regions are still loading
static func set_is_ready(source:Node, is_ready:bool):
	source.set_meta("is_ready",is_ready)
static func get_is_ready(source:Node)->bool:
	return source.get_meta("is_ready",false)

##A flag stating if the enity is busy. It is ment to remove it from being
##targeted without making it invisible. NOTE: could also handle this with group
##but would be a bit odd. Note: this is for cases where player fish, but the game
##may not pause (due to lack of layered pausing system). it would allow enemies to ignore
## or ncp to not interact with busy enities
static func set_is_busy(source:Node, is_busy:bool):
	source.set_meta("is_busy",is_busy)
static func get_is_busy(source:Node)->bool:
	return source.get_meta("is_busy",false)
	



