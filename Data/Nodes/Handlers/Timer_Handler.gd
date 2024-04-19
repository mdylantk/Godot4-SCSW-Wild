##This handles async tasks and timers in one place
##This is to have a few major timers, instead of many small timers.
##Independent times may still be used. This mostly for repeating timers(aka clocks)
class_name Timer_Handler extends Node

#NOTE: I am not sure if I will use this. dpends on the system. if they
#are self contain enough, then they can handle their own timers
#else this can be used. 
#TODO: need a way to handle world time between dim/worlds.
#could have the level data handle it as well use a generic world/game time
#that the level could yous to forward the time if nessary

##The timer responsible for world time updates. 
##these slower than processes and is meant to be a generic update tick
##that only runs when the game is not paused
func get_world_timeout()->Signal:
	return %World_Tick.timeout

##how often the AI should run steps. default processes can be used if nessary
##but AI should not need to update as often
func get_ai_timeout()->Signal:
	return %AI_Tick.timeout

##handles the update of generic generators. process could be use, but
##with this here, the update rate can be change
func get_generator_timeout()->Signal:
	return %Generator_Tick.timeout

##async sleep where time is in seconds. Extra functionality that could help debugging
func sleep(time:float = 1, process_always: bool = false) -> void:
	await get_tree().create_timer(time,process_always).timeout

