#this class is meant to be a non_node version of Raycast as well as a way to provide
#more acess to direct_space_state. It also to keep trace data contained and reusable
#this is meant to be used for short or triggered trace
class_name Collsion_Trace_2D extends Resource

@export var collide_with_areas : bool = true
@export var collide_with_bodies : bool = true
@export var hit_from_inside : bool = true
@export_flags_2d_physics var collsion_mask: int = 0b10000000_00000000_00000000_00001000

var default_exclude:Array[RID]
var query : PhysicsRayQueryParameters2D

#NOTE: this will only return one. to return more than one, the trace need to repeat
#adding hit objects to exclude

##this will reuse the query, but refresh the values
func create_query(from:Vector2, to:Vector2, exclude:Array[RID] = default_exclude):
	if query == null:
		query = PhysicsRayQueryParameters2D.create(from, to, collsion_mask, exclude)
	else:
		query.exclude = exclude
		query.from = from
		query.to = to
		query.collision_mask = collsion_mask
	query.collide_with_areas = collide_with_areas
	query.collide_with_bodies = collide_with_bodies
	query.hit_from_inside = hit_from_inside
		

##Will use the provide data to trace by line
func line_trace(
		space_state:PhysicsDirectSpaceState2D,from:Vector2, to:Vector2,
		exclude:Array[RID] = default_exclude
	) -> Dictionary: 
	create_query(to, from, exclude)
	return space_state.intersect_ray(query)
	
func multi_line_trace(
		space_state:PhysicsDirectSpaceState2D,from:Vector2, to:Vector2,
		exclude:Array[RID] = default_exclude, max_object: int = 32
	) -> Array[Dictionary] :
	var current_excludes:Array[RID] = default_exclude
	var all_results: Array[Dictionary] = []
	create_query(to, from, exclude)
	for count in range(max_object):
		query.exclude = current_excludes
		var results:Dictionary = space_state.intersect_ray(query)
		if !results.is_empty():
			all_results.append(results)
			current_excludes.append(results["rid"])
		else:
			return all_results
	return all_results
