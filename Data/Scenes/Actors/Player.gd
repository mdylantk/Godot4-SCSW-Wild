extends CharacterMovement

@onready var inventory = $Inventory


func _process(_delta):
	#update the spite to indicate hit direction
	$Direction.position = facing_dirction*12
