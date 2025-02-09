class_name Base_Hurtbox extends Node
signal hitted(attacker:Node, data:Dictionary)
#can either be dected by a hurt object and provide a hit function
#or dectect a hurt object and pull data from (like from metadata or
#checking if a hurt object. latter is better for types)

#point of this is to state it been hit. need data pass to decide on how it will
#handle it.
#hurtobject could use this owner ref and trigger events. then all this may need is a notify system.
#like if player is hit, but the hurt object is the one handling data, then only the attacker handler is known
#(if any), but if player handler is connected to signals, then it would know if there an update and forward
#it to the ui if needed

#simple system is this accept damage and an object that state the damage type and conditions
#then pass it to a damage handler. 

#data such as atack position would be useful to log. such as hit target facing pos and hit direction
#or attacker pos for cases where awarness is needed, not hit direction(such as if the attacker is seen
#or in visable range of the target)

func hit(attacker:Node,data:={}):
	#may need to forward it to a hit system before emitting
	#unless the owner will forward it(or handle it directly) since not all hit obejct
	#will have complex damage system
	hitted.emit(attacker,data)
