class_name Weighted_Action_Group extends Weighted_Group_Resource

@export var actions : Array[Base_Action] :
	set(value):
		entries = value
		actions = value

func _init(_name="name", _weight=10, _entries=actions):
	super(_name,_weight,_entries)
