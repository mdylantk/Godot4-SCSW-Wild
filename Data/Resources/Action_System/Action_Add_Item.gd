class_name Action_Add_Item extends Action
#a resource that hold logic of an action
#for the future action handler that would replace/improve interaction handler
#by handle diffrent types of action by type and (probably) state
@export var item : Item
@export var amount : int = 1
@export var meta : Dictionary = {}

static func run(data:Dictionary):
	super(data)
	var failed = false
	#run checks to see if action will work (or fail it if not)
	#basicly if target has inventory and item data is vaild
	#add the item or try to. fail it if item was not added(maybe)
	#make sure below is called correctly. it just set the state to ended so
	#the future action handler can clean finish events up
	data["type"].end(data, failed)
