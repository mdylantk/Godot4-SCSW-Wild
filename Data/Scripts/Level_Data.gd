class_name Level_Data extends Resource
#NOTE: this class is meant to be the base class of level data
#for use to handle populating generated worlds, loading static worlds,
#as well as any others. bulk logic will be in the children

#a function getting level ref at the region position. children should override this
#since the logic may need to be diffrent, it may just return an empty region data
#or it will return a tilemap scene wither from a dic or just one. it should return a scene
#since region is just a helper object and state for generation or chunk/region base logic
func get_level_scene(coords:Vector2i):
	pass
	
#once the level is pulled(if any) its data should be return for processing
#the world will handle loading and unloading the level, but new levels may
#need addition logic done and this is what this is for. (Note: it might be awaitable)
#logic be like generating foilage or full generation. unit spawning would be
#either tilemap base or another handler base. This could handle that, 
#but for now that logic can be reserve for later
#the issue is that this should not call to the world(except for signals) but
#the world can freely talk to this.
func process_region(coords:Vector2i, region:Region_Data):
	pass
