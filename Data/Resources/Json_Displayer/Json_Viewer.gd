@tool
class_name Json_Viewer extends Resource
#this is more of an example on how to work with json or to
#test if the path is vaild json path.
#todo: build system that uses json by loading it when game is ready
#and have check to make sure feilds are accessable

@export_file("*.json") var path = "res://Data/Resources/Json/Lore.json":
	set(value):
		path = value
		load_data()
@export_multiline var data : String:
	set(value):
		print_debug("Json_Viewer.data is read only")
var json : JSON
func load_data():
	var file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		var contents = file.get_as_text()
		json = JSON.new()
		json.parse(contents)
		data = str(json.data)
		file.close()
	else:
		data = ""
	notify_property_list_changed()

func _init():
	load_data()
