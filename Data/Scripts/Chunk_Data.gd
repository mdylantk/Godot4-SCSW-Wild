class_name Chunk_Data extends Resource

#@export var chunk_scene : PackedScene

@export_file("*.tscn") var chunk_scene_path : String = "res://Data/Scenes/Maps/"


@export var is_static_chunk : bool = true
@export var static_location : Vector2

#prototype for random picking
#may not be used unless a better system for catching and picking weight is designed
@export var random_weight : float = 1
