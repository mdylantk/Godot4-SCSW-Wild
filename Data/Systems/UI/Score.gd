extends CanvasLayer


@export var text_template := "{id}: {score}"

func set_common_score(value:int) -> void:
	%Score_0.visible = value != 0
	set_score(%Score_0,"Common",value)
func set_rare_score(value:int) -> void:
	%Score_1.visible = value != 0
	set_score(%Score_1,"Rare",value)

func set_score(label:Label, id:String, score:int):
	label.text = text_template.format({"id": id, "score": score})
	visible = (%Score_0.visible || %Score_1.visible)
