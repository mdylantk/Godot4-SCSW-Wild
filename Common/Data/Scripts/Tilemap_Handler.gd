##this is to handle tilemap layers and expose some globlly with keywords(tag) or id
class_name Tilemap_Handler extends Node2D

#NOTE: THIS MAY NOT NEED ALL THESE FUNCTIONS
#the generator logic is handled by the scene (or the child of this)
#so all that would be needed is helper functions
#is_tile_modifiable wont be needed, though might keep some of the others
#the issue is that tile layers may not be known
#ALSO could keep it all and just expect the layers to be assign if used
#this means that only the assign layers will be exposed to logic in the children


@export var tilemap_layers:Array[TileMapLayer]

var is_ready : bool = false

func get_tilemap_layer(index:int)->TileMapLayer:
	if tilemap_layers.size() > index:
		return tilemap_layers[index]
	return null
	
func get_tilemap_layer_by_id(id:String)->TileMapLayer:
	return null
	

func get_tile(coords:Vector2i=Vector2i(),layer_index:int=0)->TileData:
	if tilemap_layers.size() > layer_index:
		return tilemap_layers[layer_index].get_cell_tile_data(coords)
	return null
	
func get_tiles(coords:Vector2i=Vector2i())->Array[TileData]:
	var tiles:Array[TileData]
	for tile in tilemap_layers:
		tiles.append(tile.get_cell_tile_data(coords))
	return tiles
	
func set_tile(
	coords: Vector2i, 
	source_id: int = -1, 
	atlas_coords: Vector2i = Vector2i(-1, -1), 
	alternative_tile: int = 0,
	layer_index:int=0
	)->bool:
	if tilemap_layers.size() > layer_index:
		tilemap_layers[layer_index].set_cell(coords,source_id,atlas_coords,alternative_tile)
		return true
	return false

##an overrided function to compare the state of the tile
##for example if tage is foilage then child could check to see if any tiles in other
##layers are blocking "foliage: from spawning
func is_tile_modifiable(coords:Vector2i, tags:Array[String] = [])->bool:
	#will consider any vaild tile as blocked. children can override this
	for tile in tilemap_layers:
		if tile.get_cell_tile_data(coords):
			return false
	return true
	
func _ready() -> void:
	is_ready = true
