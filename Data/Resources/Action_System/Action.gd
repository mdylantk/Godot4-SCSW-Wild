class_name Action extends Resource
#a resource that hold logic of an action
#Note: should change to static and add an action handler
#so a dictionary is used to store action info

func new_action(source = null, target = null):
	return {"action":self, "source":source, "target":target, "state":"init"}
	#NOTE: the action will be instanced so it can be modified in editor.
	#may be best if this is not static so it can get a ref to self

static func run(data:Dictionary):
	if data != null:
		data["state"] = "running"

static func tick(data:Dictionary):
	pass

static func end(data:Dictionary, canceled:bool = false):
	if data != null :
		data["state"] = "ending"
		data["canceled"] = canceled
