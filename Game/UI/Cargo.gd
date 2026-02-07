##this is a test inventory for advance item and structure may change
extends Canvas_Scene

@export var player_state : Player_State = Player_State.get_default_instance()

#need to keep track of them so they can be disconnected
#could probably disconnectif called and not in inventory
#but this be more reliable
var items : Array

#may need to call this item selected or something
var last_item_selected:int = -1

var refresh_flagged:bool = false
var update_flagged:bool = false

func get_item(index)->Item:
	if player_state.advance_inventory.size() > index && index >= 0:
		return player_state.advance_inventory.get(index)
	return null
	
##Check to see if there an item in list at the index.
func item_is_in_list(index)->bool:
	return %ItemList.item_count > index
	
func get_item_display_name(item:Item)->String:
	if item:
		if item.amount > 1 :
			return '{0}({1})'.format(
				[item.item_type.display_name,item.amount]
			)
		else:
			return item.item_type.display_name
	return ''

#add a new item at the end of the list
func add_item(item:Item)->void:
	if item:
		%ItemList.add_item(
			get_item_display_name(item),
			item.item_type.icon
		)
		item.changed.connect(_on_item_changed)
		items.append(item)
	else:
		%ItemList.add_item('null')

func update_info(item:Item)->void:
	if item == null:
		clear_info()
		return
	%Name.text = item.item_type.display_name
	%Discription.text = item.item_type.discription
	%Meta.clear()
	%Meta.add_item(str('amount:',item.amount,'/',item.item_type.max_stack_size))
	%Meta.add_item(str(
		'weight:',item.amount*item.item_type.base_weight*item.metadata.get('size',1.0))
	)
	#NOTE: meta display is mostly for debugging. some meta would need to
	#be displayed or used to replace existing info, but for now
	#this will display as much meta that will fit
	for key in item.metadata.keys():
		%Meta.add_item(str(key,': ', item.metadata[key]))
	%Meta.visible = true
	if true: #TODO: Check if fish item type when such is created
		var log = player_state.fish_log.get_log_of_fish(item.type_uid)
		%Meta.add_item(str('total caught: ',log.get(Fish_Log.COLLECTION_TYPE.keys()[0],0)))
		%Meta.add_item(str('total delvivered: ',log.get(Fish_Log.COLLECTION_TYPE.keys()[1],0)))
	
func clear_info()->void:
	%Name.text = ''
	%Discription.text = ''
	%Meta.clear()
	%Meta.visible = false

func deselect_item(index:int)->void:
	if index >= 0 && item_is_in_list(index):
		%ItemList.deselect(index)
	clear_info()
	last_item_selected = -1

func select_item(index):
	if index >= 0 && item_is_in_list(index):
		%ItemList.select(index)
		update_info(get_item(index))
		last_item_selected = index
	else:
		deselect_item(index)

func clear()->void:
	for item :Item in items:
		if item.changed.is_connected(_on_item_changed):
			item.changed.disconnect(_on_item_changed)
	%ItemList.clear()

func update_item(index:int,item:Item)->void:
	if item_is_in_list(index):
		if item:
			%ItemList.set_item_icon(index,item.item_type.icon)
			%ItemList.set_item_text(index,get_item_display_name(item))
		else:
			#todo: clear the icon
			%ItemList.set_item_text = 'null'
		#if the items are diffrent. disconnect from the olf
		#and update it. items array is for keeping track of connections
		#also if this accure, then should deselect the item since it is diffrent
		var old_item: Item = items.get(index)
		if !item.is_similar_to(old_item):
			if old_item:
				old_item.changed.disconnect(_on_item_changed)
			items.set(index,item)
			#deselect the changed value
			if index == last_item_selected:
				deselect_item(index)

func update_items()->void:
	update_flagged = false
	if refresh_flagged:
		return
	for i in range(%ItemList.item_count):
		var item : Item = get_item(i)
		if item:
			update_item(i,item)

func refresh_item_list()->void:
	clear()
	refresh_flagged = false
	update_flagged = false
	items.clear()
	for item in player_state.advance_inventory:
		add_item(item)
	select_item(last_item_selected)

func on_advance_inventory_changed(index:int=-1) -> void:
	if refresh_flagged:
		return
	if player_state.advance_inventory.size() != %ItemList.item_count && !refresh_flagged:
		refresh_flagged = true
		call_deferred('refresh_item_list')
		return
	#if index >= 0 && item_is_in_list(index):
	#	%ItemList.deselect(index)
	if update_flagged:
		return
	var item : Item = get_item(index)
	if item:
		update_item(index,item)
	return
	
func _on_item_list_item_selected(index: int) -> void:
	var item : Item
	if index >= 0:
		if index == last_item_selected :
			deselect_item(index)
			index = -1
		item = get_item(index)
	
	if item:
		update_info(item)
		last_item_selected = index
	else:
		clear_info()
		last_item_selected = -1


func _on_item_changed()->void:
	if !update_flagged:
		update_flagged = true
		call_deferred('update_items')
#a test
func _on_button_pressed() -> void:
	var item_type = load('uid://db8k4softx2h4')
	player_state.set_item(Item.new(item_type),1)


#func start()->void:
#	super()
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func end()->void:
	super()
	if last_item_selected >= 0 && item_is_in_list(last_item_selected):
		%ItemList.deselect(last_item_selected)

func _on_visibility_changed() -> void:
	pass
	#if visible:
	#	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#else:
	#	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	#	if last_item_selected >= 0 && item_is_in_list(last_item_selected):
	#		%ItemList.deselect(last_item_selected)

#func _input(event: InputEvent) -> void:
#	if event.is_action_pressed('Inventory'):
#		visible = !visible

func _ready() -> void:
	player_state.advance_inventory_changed.connect(on_advance_inventory_changed)

func _on_exit_pressed() -> void:
	end()
