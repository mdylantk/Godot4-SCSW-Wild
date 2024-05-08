extends Character2D

@onready var inventory = $Inventory


func _process(_delta):
	#update the spite to indicate hit direction
	$Direction.position = movement_component.facing_dirction*12

func interact():
	%RayCast2D.target_position = movement_component.facing_dirction * 24
	%RayCast2D.force_raycast_update()
	if %RayCast2D.get_collider() != null:
		var data := {
			"source":self,
			"target":%RayCast2D.get_collider().owner,
			"collider":%RayCast2D.get_collider(),
			"collider_rid":%RayCast2D.get_collider_rid()
		}
		interacted.emit(self, %RayCast2D.get_collider(),data)
