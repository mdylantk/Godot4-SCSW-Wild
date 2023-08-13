extends Node2D

#todo: this handles loading, unloading, and culling instances
#also: could have game handle loading and unloading these handler
#so the getter just get a ref to what is loaded
#but require wither having a common level handler parent or abstrat any calls to it 
#to not need it.

#instances here are generaly scenes loaded in for a unquie area. 
#most of what is loaded could be handle in the children while this acts
#as a way to comunicate with them

#common feature in all level like handlers is hiding and/or unloading non-visable 
#chunks to improve performance.
#as well as have common funtonality to act like an interface between the world and game.
