extends CanvasLayer

@export var player_state : Player_State = load('uid://c67c2fehtuhni')

#NOTE: since items are stored as a dictionary, it be best to
#store the items here so a new instance is not needed when reading it
var items : Array

var last_item_selected:int = -1

#could change each element. but need to track the inventory index
#and pass the data. 
func on_advance_inventory_changed() -> void:
	%ItemList.clear()
	for item_data in player_state.advance_inventory:
		var item : Item = Item.new()
		item.load_from_dict(item_data)
		var item_type = item.item_type
		if item.amount > 1:
			%ItemList.add_item(
				item_type.display_name + '(' + str(item.amount) + ')',
				item_type.icon
			)
		else:
			%ItemList.add_item(item_type.display_name, item_type.icon)
		items.append(item)
	#TODO: when switching to a per item update,
	#this should only reset it if the item selected changed or removed
	_on_item_list_item_selected(-1)
		

func _on_visibility_changed() -> void:
	if visible:
		pass
	else:
		_on_item_list_item_selected(-1)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('Inventory'):
		visible = !visible

func _ready() -> void:
	player_state.advance_inventory_changed.connect(on_advance_inventory_changed)


func _on_item_list_item_selected(index: int) -> void:
	var item : Item
	if index >= 0:
		if index == last_item_selected :
			%ItemList.deselect(index)
			index = -1
		else:
			item = items.get(index)
	if item:
		%Name.text = item.item_type.display_name
		%Discription.text = item.item_type.discription
		%Meta.clear()
		%Meta.add_item(str('amount:',item.amount,'/',item.item_type.max_stack_size))
		%Meta.add_item(str('weight:',item.amount*item.item_type.base_weight))
		#NOTE: meta display is mostly for debugging. some meta would need to
		#be displayed or used to replace existing info, but for now
		#this will display as much meta that will fit
		for key in item.metadata.keys():
			%Meta.add_item(str(key,': ', item.metadata[key]))
		last_item_selected = index
		%Meta.visible = true
	else:
		%Name.text = ''
		%Discription.text = ''
		%Meta.clear()
		last_item_selected = -1
		%Meta.visible = false
