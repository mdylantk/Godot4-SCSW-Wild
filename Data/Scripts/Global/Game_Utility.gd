class_name Game_Utility extends Object
#this contains static function for game basen logic
#ideally for checks and getters that related to the 
#game as a whole. 
#NOTE: some functionality could find home elsewhere if
#that other home make more sence. In this case, most
#sceiots that call theses functions should be game
#level instead of being called in moduals or subsystem

#note: this should return an resource of type action
#the idea is to get an action object and then run the logic
#a null check may be needed if a null action dose not exists
#shouls it should return a null type if no vail;d action exists
static func get_action(source, action_id : String):
	#NOTE: this should return a callable
	if source.has_method(action_id):
		return source[action_id]
		#return func(data): return source[action_id].call(data)
		#event["run"].call(event) 
	#need a metadata check. also need to check if 
	#the source[id] will return a varible.
	#probably should return a callable to run
	#TODO: return a callable to run.
	#this will solve the null issue and create a weak
	#interface at the cost of the overhead of a runnable
	#and a static function call

	return func(handler, instigator, interactee, data): 
		pass #note may need to return some data?
