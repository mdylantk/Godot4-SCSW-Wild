class_name Item_Type extends Resource

@export var display_name : String = "Item"
@export var discription : String = "This is an item"
@export var tooltip : String = "tooltip of item"
@export var icon : Texture
#the object to spawn if item can be drop or spawn in world. most likly will be a use a share item entity
#but that may not always be wanted(also a meta tag could override this
@export_file("*.tscn") var item_entity : String
