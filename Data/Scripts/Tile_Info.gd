class_name Tile_Info extends Resource

#the point of this is to be a simple version of tiledata, but for
#containing info about a tile location in the game
#it caould be extended upon to aply unqiue data to a tile via a resource id
#Note that this will not work with the tile editor so it more for generated tile
#or tiles place at runtime or perhaps even interative with(but that would require reverse lookup)

#the tileset the tile is from
@export var tileset : TileSet
#the layer the tile is in. -1 for NA. This just state where to look or add the tile
#in cases where layer pacement is sensitive
@export var layer_id : int
#the position of where the tile is on the tileset. 
@export var tileset_position : Vector2

#TODO either make a res that hold tileset ref and position or use this for that
#the idea is to ref various tiles as a sort of variation
#also may need to add multi layer support but that more advance and this 
#system uses a single layer for tiles
