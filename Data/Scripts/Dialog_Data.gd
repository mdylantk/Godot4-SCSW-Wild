class_name Dialog_Data extends Resource

@export var id : String = "generic_dialog"
@export var name : String = "generic_name"
@export var icon : Texture2D 
@export var default_text_is_random : bool = false #instead of having long default text, this would allow smaller text to be sampled from
@export var visited : bool = false #will bypass into if true. 
@export var save_visited_flag : bool = true #will save if the talker been visited at least once if true. this for cases when non random ncp need to speek into once(like the old man)

@export var intro_text : Array[String]
@export var default_text : Array[String]

@export var other_text : Dictionary # other topics would be stored here. key is the topic, and the values is an array of strings

func get_text(index = 0, override_id = null): #index is ignored if default and random. also invald may be treated as 0 or return null
	var text_source
	var is_into = false
	if index < 0:
		index = 0
	if override_id == null:
		if visited:
			if default_text_is_random :
				if default_text.size() > 0 && index <= 0 :
					return default_text[randi() % default_text.size()]
				else:
					return null #only allow random is index is 0. also return null if size is empty
			else:
				text_source = default_text
		else:
			text_source = intro_text
			is_into = true #for setting the visited flag after reaching the end
		#check if local flag is set
			#if false, check if global flag is set
		#use flag to decide if it is into or default
		#NOTE: the flag may be saved for the session due to this being a static resource..just not for saves so still need the global var
		pass
	elif override_id == "intro_text":
		text_source = intro_text
		is_into = true
	elif override_id == "default_text":
		text_source = default_text
	else:
		if other_text.has(override_id):
			text_source = other_text[override_id]
		else:
			return null
	if index < text_source.size():
		return text_source[index]
	else:
		if is_into:
			visited = true
		return null
	
##NOTE: the is_visit var is reset when ncp is unloaded so global var is needed
#so intro play once and then the id is catch in global
#then default is used.
#if ncp have it own code or a quest logic is running, it can grab data from other text if it exist
#this here just to hold text. logic can happen elsewhere if 
