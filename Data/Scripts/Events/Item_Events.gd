class_name Item_Events extends Object

#This is a static function libraray for event related to items
#data is pass from the first parametter which should be a dictionary
#or class if the system change. The logic is base on the game, but
#function calls should be used instead of directly setting values
#so functions wont be pure. they will only lack a state

static func acquire_item(target,item,handler = null,prefix = "Acquired"):
	#NOTE: for the fish logic. it will pick first then run the add item logic
	#this handler gaining an item.
	#target gains any items in data 
	#and if any items are gain, then notify the source
	#the notifying may be best with a callable they provide
	#so the excact logic wont need to be assumed
	print_debug("starting")
	var remaining_amount = target.inventory.add_item(item)#.duplicate(true))
		#need to make sure the memory is not clear or lost for item
	if remaining_amount >= 1:
		print_debug("can not carry anymore fish")
		General_Events.send_notifcation(
			handler, 
			prefix +" "+ str(item["meta"]["name"]) + " but unable to carry anymore."
			)
	elif handler != null:
		General_Events.send_notifcation(
			handler, 
			prefix +" "+ str(item["meta"]["name"])
			)
		#handler.get_hud().gui_notify.add_notify_message(
		#	"[center]"+prefix +" "+ str(item["meta"]["name"])
		#	)
		#print_debug(target.inventory.items)
	return remaining_amount
