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
	#NOTE: action_id should be on_[action] in hope to reduce
	#chances of that id being used
	elif source.has_meta(action_id):
		var action_data = source.get_meta(action_id)
		#NOTE: if it not the correct type, the game would break.
		#could add aditional checks if nessary
		return action_data[action_id]
	else:
		return func(handler=null, instigator=null, interactee=null, data={}): 
			pass #note may need to return some data?
