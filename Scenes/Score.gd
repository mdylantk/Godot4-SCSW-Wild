extends CanvasLayer

@onready var score_text = $ScoreText

func update_text(common = 0, rare = 0):
	score_text.text = "[center]Common: " + str(common) + " Rare: " + str(rare)

func _process(_delta):
	if Global.rare_fish_count <= 0 and Global.common_fish_count <= 0:
		visible = false
	else:
		if !visible:
			visible = true
		update_text(Global.common_fish_count, Global.rare_fish_count)
		
