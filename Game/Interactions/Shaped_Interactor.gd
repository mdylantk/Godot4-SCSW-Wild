class_name Shaped_Interactor extends Node
signal interaction(interactor, collider,data)
@export var shape_cast : ShapeCast2D

#TODO: See how this is working
#if not being used, then remove in favor
#of direct cast control
#NOTE: Look like it is still being used
#wont be easy to have a drag and drop approch
#so may need to add the logic to each character
#or the characer2D. issue is there are two type of casts
#generally it get trigger, do a force update, and then 
#parce the results
#NOTE: could use area 2d to do this too
#may be able to use an action that trigger interaction logic
#then all the character need to do is trigger the interaction 
#component on keypress. issue is the data pass might be a bit odd
#so a dedicated componet to triggering may be more ideal
#NOTE: using shapecast instead of area2d for hit order
#also can use a line trace as a provide shape

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
