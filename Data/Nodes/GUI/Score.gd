extends CanvasLayer

@onready var score_text = $ScoreText

var score_data : Dictionary = {}

func update_data(data :Dictionary = {}) :
	score_data = data
	if data.is_empty():
		visible = false
		#hide
	else:
		var new_text = "[center]"
		for score_name in score_data:
			new_text += str(score_name) + ": " + str(score_data[score_name]) +"\n"
		score_text.text = new_text
		visible = true
		#change and make visible
