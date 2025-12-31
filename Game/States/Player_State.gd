class_name Player_State extends State
#NOTE: this is still depenent on data from savable state
#one the few varibles that depends on it is moved to their deicated
#properties (or a none exportable data is added and hook up), then it can be
#transfered

signal score_changed(id:String, new_value:int)


var scores : Dictionary[String,int] = {}

#sets of bitflag ints instead of using
#an array of bools. reserver for when data gets compress
#otherwise data will be used
var flags : Array[int] = [] 

var positions : Dictionary[String,Vector2] = {}

#TODO: look into inventory to see how uid or path is extracted
#or fine a way to extracted.
var pawn #NOTE: this should be the pawn class or a savable data struct for rebuilding the pawn
#could store this in positions 
var world_position : Vector2 #this should be set when traveling or saving. global_position should be used
#for the actual position

#items will be player owned inventory
#cargo will be specail items owned by the player
#such as trade goods, dynamic items, or gear and will have its own limits
#it probababy store it in a easier to save (do not depend on an object)
#and anything that display it should parse that data into the proper item object
#NOTE: this means the version here should convert all object ref to a dict of its state
#or uid string ref.
#stash (if added) will be a mix of the two or just the latter
#for a protective storage
##an dictionary of iten uid(for linking display info) and quanities of that item
var standard_inventory : Dictionary[String,int]
var advance_inventory : Array[Dictionary]

#NOTE: instance may not be used. exit_data should have the basic data for loading
#the last level before exiting
var instance = null #the instance the player is in. mostly for loading reasons. 
#may use position instead
var instance_position : Vector2 #similar to world position, but used when loading into an instance
#so set when saving or before loading into an instance from world. (but instance may override it coded that way)

#Exit data is used for loading last zone
#NOTE: may need to rethink this. may embed it in here
#so another resource is not used. should try using basic types
#over object when possible or have a stringify function for them
#and vice versa
@export var exit_data : Exit_Data = Exit_Data.new()
#these are the character last state to be saved
#so they load in like how they load out
#also could change positions to handle thesem but facing be odd
#could also have an object that handles it
@export var position : Vector2
@export var facing : Vector2


#TODO: it is unlikly there be more than one location to store of the player state
#and if there more than one "world" each can have a dedicted varible or the others
#can be added as a meta
#var world_location : Vector2

func set_score(id:String, new_score: int)->void:
	var old_score = 0
	if id in scores:
		old_score = scores[id]
	scores[id] = new_score
	#if old_score != new_score:
	score_changed.emit(id,new_score)
	value_changed.emit(id+"_score",new_score,old_score)
	print_debug("meow! set score of ", self, old_score, '->', new_score,' ', id)
	
func get_score(id:String)->int:
	if id in scores:
		return scores[id]
	return 0

#Note: item pass amount will be changed based on what is taken from it
#so it will have an amount of 0 unless not all of the item was used up
#so it may be better to pass a dupicate of the item if the item amount need
#to stay fixed (aka was not created per task but pulled from a tres or export)
func add_item(new_item:Item)->void:
	if new_item == null:
		return
	var item_type : Item_Type = new_item.get_type()
	if item_type == null:
		return
	if item_type.is_unique:
		var remaining_amount : int = new_item.amount
		if remaining_amount > 0:
			for item_data in advance_inventory:
				var item : Item = Item.new()
				item.load_from_dict(item_data)
				if item.is_similar_to(new_item):
					remaining_amount = item.increase_amount(remaining_amount)
					#might be able to set amount directly, but
					#this is safer if it works since wont depend on a
					#string identifier outside of item
					item_data.assign(item.convert_to_dict())
					#slot_update.emit(self,0,item)
			#TODO: change 100 to a max inventory value
			for new_slot in range(100-advance_inventory.size()):
				if remaining_amount > 0:
					var new_item_stack : Item = new_item.duplicate()
					var new_amount = remaining_amount
					if remaining_amount > item_type.max_stack_size:
						new_amount = item_type.max_stack_size
						remaining_amount = remaining_amount - new_item_stack.max_stack_size
					else:
						new_amount = remaining_amount
						remaining_amount = 0
					new_item_stack.amount = new_amount
					advance_inventory.append(new_item_stack.convert_to_dict())
					#inventory.append(new_item_stack)
					#slot_update.emit(self,inventory.size()-1,new_item_stack)
				else:
					break
		elif remaining_amount < 0:
			var orignal_size = advance_inventory.size()
			for i in range(orignal_size):
				var slot = orignal_size - (i+1)
				var item_data = advance_inventory.get(slot)
				var item = null
				if item_data:
					item = Item.new()
					item.load_from_dict(item_data)
				if item.is_similar_to(new_item):
					remaining_amount = item.increase_amount(remaining_amount)
					if item.amount <= 0:
						advance_inventory.remove_at(slot)
						#slot_update.emit(self,slot,item)

	else:
		#would need to store the non object ref to make saving/loading easier
		var old_amount : int = standard_inventory.get(new_item.type_uid,0)
		var new_amount : int = clamp(old_amount + new_item.amount,0,item_type.max_stack_size)
		new_item.amount -= new_amount
		
		standard_inventory.set(new_item.type_uid,new_amount)
		#NOTE: decide if it should return a value representing
		#what is left over
	#TODO: check item is unique to see if it is stored as a 
	#stardard(false) item or advance(true)
	#make sure that item has an amount, else make sure to add amount as a parameter
	#if advance, make sure to convert to a dictionary that do not hold any ref to object.
	pass

func _reset_state() -> void:
	#data.clear()
	exit_data = Exit_Data.new()
	scores = {}
	positions = {}
	position = Vector2.ZERO
	facing = Vector2.ZERO
	flags = []
	standard_inventory.clear()
	advance_inventory.clear()
	
func get_save_data()->Dictionary[String,Variant]:
	saving.emit()
	var save_data : Dictionary[String,Variant]
	save_data.set('exit_data',exit_data)
	save_data.set('scores',scores)
	save_data.set('positions',positions)
	save_data.set('position',position)
	save_data.set('facing',facing)
	save_data.set('flags',flags)
	
	save_data.set('standard_inventory',standard_inventory)
	save_data.set('advance_inventory',advance_inventory)
	
	save_data.set('data',get_metadata())
	
	return save_data
	

#and load will load the pass data (if changed) and then notify
#all that it is ready(aka loaded)
func load_data(new_data:Dictionary[String,Variant]={})->void:
	exit_data = new_data.get('exit_data',exit_data)
	scores = new_data.get('scores',scores)
	positions = new_data.get('positions',positions)
	position = new_data.get('position', position)
	facing = new_data.get('facing', facing)
	flags = new_data.get('flags', flags)
	
	standard_inventory = new_data.get('standard_inventory', standard_inventory)
	advance_inventory = new_data.get('advance_inventory', advance_inventory)
	
	set_metadata(new_data.get('data', get_metadata()))
	#data = new_data.get('data', data)
	loaded.emit()
