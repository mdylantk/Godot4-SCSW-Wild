class_name Interactive_Data extends Resource

#NOTE: the owner may handle the action lifecycle or just store ref
#to it. most action would be one-shots. extended ones would lack a
#dedicated system and will act like one instead. these are not ideal
#but this is set up in a way to handle those cases(atm not impumented
#since no case needs it)
signal started(data:Interactive_Data)
signal updated(data:Interactive_Data)
signal finished(canceled : bool,data:Interactive_Data)

#A node of a scene that assume to be a character2d in this project
var interactor : Node :
	set(new_value):
		if interactor != new_value:
			interactor = new_value
			emit_changed()

#A node of a body that is assume to be an interactive component in this project
var interactee:
	set(new_value):
		if interactee != new_value:
			interactee = new_value
			emit_changed()

#metadata related to this action. could use object metadata, but 
#not sure if that is safe to save
var data : Dictionary:
	set(new_value):
		if data != new_value:
			data = new_value
			emit_changed()

var _is_active : bool 

#TODO decided if update rate should be exposed since children can not make an override
#export. also the children would be manually setting this base on the logic
#may have an override @export varible to controll the rate
var _update_rate : int

func interact(new_interactor, new_interactee, new_data):
	if _is_active:
		print_debug("interaction is already active")
		return false
	interactor = new_interactor
	interactee = new_interactee
	data = new_data
	_is_active = true
	_run()
	return true

func end_interact(canceled:bool = false):
	_end(canceled)
	finished.emit(canceled,self)
	_is_active = false

#the default run logic. will call all the steps with an update cycle if vaild
func _run():
	_start()
	started.emit(self)
	#print_debug(str(interactor) + " interact with " +str(interactee) + " from(handler) " +  str(handler))
	while _update_rate and _is_active:
		#NOTE: this class ment to be generic. it should not have these function
		#but it can be useful. So base godot logic should only be here (or just declartion)
		await interactee.get_tree().create_timer(_update_rate).timeout
		_update()
		updated.emit(self)
	end_interact()


#call on the start
func _start():
	pass
	
#call per update if it can
func _update():
	pass
	#updated.emit(data)

#called when the interaction is consider over
func _end(canceled:bool = false):
	pass
	#finished.emit(true,data)
