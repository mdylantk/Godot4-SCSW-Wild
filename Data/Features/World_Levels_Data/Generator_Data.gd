class_name Generator_Data extends Resource

signal scene_finished(generator : Generator_Data, scene:Node)
signal data_finished(generator : Generator_Data, data:Array)
#this hold base function for a world generator. 
#foilage or world generation are the main goals. but also mazes

#WHAT IF: pass some node to work on and a flag stating a full wipe or standard generation
#also need constrants like bounds. could probably get tile size from map.
#would have a tilemap pass and assume 2d

#NOTE: no need for a bounds since the generator in most cases should be shared
#for a world and thus @export can provide the bounds
#should an array be passed? but too big of a size could be an issue
func generate(scene:Node):
	scene_finished.emit(self,scene)


#an optional one that can use data incase more than one generator need to run
#will use data instead of scene since it should not modify the scene, just the data
func generate_with_data(data: Array):
	data_finished.emit(self, data)
