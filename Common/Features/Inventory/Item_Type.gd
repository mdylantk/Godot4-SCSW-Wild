class_name Item_Type extends Resource

@export var display_name : String = "Item"
@export var discription : String = "This is an item"
@export var tooltip : String = "tooltip of item"
@export var icon : Texture

@export_file("*.tscn") var item_entity : String
