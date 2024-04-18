extends CanvasLayer

@onready var score_text = $ScoreText

var score_data : Dictionary = {}

#TODO: have this use a func that takes an id and value.
func update_data(data :Dictionary = {}) :
	if !data.is_empty(): score_data = data #NOTE: this is temp to test new approch
	if score_data.is_empty():
		visible = false
		#hide
	else:
		var new_text = "[center]"
		for score_name in score_data:
			new_text += str(score_name) + ": " + str(score_data[score_name]) +"\n"
		score_text.text = new_text
		visible = true
		#change and make visible
