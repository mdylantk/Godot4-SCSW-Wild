class_name Weighted_Group_Resource extends Resource

@export var name : String = "Name"
@export var weight: int = 10
@export var entries : Array

func _init(_name="name", _weight=10, _entries=[]):
	name = _name
	weight = _weight
	entries = _entries
