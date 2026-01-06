extends CanvasLayer

@export var player_state : Player_State = load('uid://c67c2fehtuhni')

#NOTE: since items are stored as a dictionary, it be best to
#store the items here so a new instance is not needed when reading it
var items : Array

var last_item_selected:int = -1

#TODO Add signals to the item and use that to update the item
#and make it so that only slot changes are notified on the inventory
#that would reduce duplicate calls and allow each fields to have
#their own call
#NOTE TODO: if an item is removed not from the end,
#the array structure changes. so need to
#make sure all item past the index of the removed item is updated
func update_item_slot(index:int)->void:
	#%ItemList.set_item_icon()
	var updated_item:Item 
	if player_state.advance_inventory.size() > index:
		updated_item = player_state.advance_inventory.get(index)
	if updated_item:
		if %ItemList.item_count > index:
			%ItemList.set_item_icon(index,updated_item.item_type.icon)
			if updated_item.amount > 1:
				%ItemList.set_item_text(index,updated_item.item_type.display_name + '(' + str(updated_item.amount) + ')')
			else:
				%ItemList.set_item_text(index,updated_item.item_type.display_name)
		else:
			if updated_item.amount > 1:
				%ItemList.add_item(
					updated_item.item_type.display_name + '(' + str(updated_item.amount) + ')',
					updated_item.item_type.icon
				)
			else:
				%ItemList.add_item(updated_item.item_type.display_name, updated_item.item_type.icon)
	elif %ItemList.item_count > index:
		%ItemList.remove_item(index)
		#NOTE: This could cause issues
		#need to redesign this to have better flow
		#full update when an item is removed and
		#selective update when item signals are emited
		#could also just do a full update when slot changes
		if index != -1:
			on_advance_inventory_changed(-1)
	pass
#could change each element. but need to track the inventory index
#and pass the data. 
#NOTE: may need to give the state a get item that returns an item
#this will return an item which the state can manage which may allow
#items to emit signals without instance issues
func on_advance_inventory_changed(index:int=-1) -> void:
	if index >= 0:
		update_item_slot(index)
		_on_item_list_item_selected(-1)
		#return so below dose not run
		return
	%ItemList.clear()
	items.clear()
	for item in player_state.advance_inventory:
		#var item : Item = Item.new()
		#item.load_from_dict(item_data)
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
		elif player_state.advance_inventory.size() > index:
			item = player_state.advance_inventory.get(index)
			#item = items.get(index)
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

#a test
func _on_button_pressed() -> void:
	on_advance_inventory_changed()
	#the ref seems correct, just need to be careful about signals
	#item might not have signals except for when data change
	#so the state may need to provide ways to notify change or
	#catch item to reduce item data sharing between two objects
	#var test_item = player_state.advance_inventory.get(0)
	#var amount = test_item.get('amount',0)
	#print_debug('mew1: ', amount )
	#test_item.set('amount',amount + 1)
	#print_debug('mew2: ', test_item.get('amount',0), ' vs ', items.get(0).amount)
	
	pass # Replace with function body.
