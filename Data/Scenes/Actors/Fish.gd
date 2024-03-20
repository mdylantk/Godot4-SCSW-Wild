extends CharacterBody2D

@export var fish_name = "Fish"
@export var rare_catch = true

@export var fish_item : Item
@export var interaction_data : Interactive_Data = Catch_Fish.new()

#@export var rare_fish_names = [
#	"Rainbow Trout",
#	"Moon Koi",
#	"Black Bass",
#	"Silver Guppy",
#	"Shadow Pike",
#	"Orange Eel",
#	"Fade Barb",
#	"King Walleye",
#	"Killer Salmon",
#	"Triple Perch",
#	"Apple Carp",
#	"Snake Eel", 
#	"Doom Pike"
#]
#@export var common_fish_names = [
#	"Carp",
#	"Koi",
#	"Bass",
#	"Eel",
#	"Barb",
#	"Pike",
#	"Perch",
#	"Salmon",
#	"Guppy",
#	"Walleye",
#	"Trout"
#]
var starting_location

func _ready():
	starting_location = global_position
	interaction_data.finished.connect(on_interact_end)

func on_interact(handler, instigator, target, data):
	if interaction_data != null:
		interaction_data.interact(handler, instigator, self, data)
		return data
			
func on_interact_end(canceled:bool, data:Dictionary):
	if !canceled:
		remove_self()

func remove_self():
	#TODO: Need a way without ref to parent
	var self_ref = self
	get_parent().remove_child(self_ref)
	self_ref.queue_free()
