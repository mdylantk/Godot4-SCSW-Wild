class_name Shaped_Interactor extends Interactor_Base

@export var shape_cast : ShapeCast2D

func interact(interactor:Node = owner):
	if shape_cast != null :
		if shape_cast == null or !is_inside_tree(): return
		shape_cast.force_shapecast_update()
		var results :Array = shape_cast.collision_result
		var data :={"source":self}
		if !results.is_empty():
			data["collider"] = results[0].collider
			data["collision_results"] = results
			if data["collider"].owner != null:
				data["target"] = data["collider"].owner
			else:
				data["target"] = data["collider"]
			interaction.emit(interactor, data["collider"],data)
