extends Node
#var move_direction :Vector2 = Vector2()

#func get_move_direction()->Vector2:
	#return move_direction
#func _physics_process(delta: float) -> void:
	
	#movement_component.apply_forces(self,delta)
	#velocity = movement_component.calculate_forces_velocity(self,delta)
	#for index in get_slide_collision_count():
	#	var collision: KinematicCollision2D = get_slide_collision(index)
	#	if collision:
	#		velocity += collision.get_normal() * collision.get_collider_velocity().length()
		
	#move_and_slide()
	#super(delta)
	#move_direction = Vector2()
	#for area in $Area2D.get_overlapping_bodies():
	#	if area is CharacterBody2D:
	#		move_direction += global_position - area.global_position
	#move_direction.normalized()
	#super(delta)
	#movement_component.clear_force("push")


#func _on_area_2d_body_entered(body: Node2D) -> void:
	#return
	#if body is CharacterBody2D:
	#	movement_component.add_additional_force(body.velocity.length(),body.velocity.normalized(),"push")
