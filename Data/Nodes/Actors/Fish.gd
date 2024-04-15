extends CharacterBody2D

func remove_self():
	#TODO: Need a way without ref to parent
	var self_ref = self
	get_parent().remove_child(self_ref)
	self_ref.queue_free()


func _on_interact_component_finished(canceled:bool, data:Interactive_Data):
	if !canceled:
		remove_self()
