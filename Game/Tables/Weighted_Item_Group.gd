class_name Weighted_Item_Group extends Weighted_Group_Resource

@export var items : Array[Item_Type] :
	set(value):
		entries = value
		items = value

func _init(_name="name", _weight=10, _entries=items):
	super(_name,_weight,_entries)
