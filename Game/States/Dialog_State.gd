class_name Dialog_State extends State
#tell the dialog ui/handler to start. 
signal start()
#started is for the speaker and other listerners to know it is ready
signal started()
#end request the ui/handler to end the dialog. if canceled, then
#the dialog is not progressed. This is more useful for things listening to
#ended
signal end(canceled:bool)
#this is to notify the listerners that the dialog is finish. 
#canceled will let it know if it was force to end early
signal ended(canceled:bool)
#this is to let listener that an accept button was clicked
#id is some kind of identifier like the index of serveral accept options
signal accepted(id)
#canceled is to notify that the canceled button is clicked
signal canceled()
#Notify the ui that there are changes. may pass flags later
#to limit what get updateded
#also may only want to call this when some properties are 
#changed at times they are normally not expected to
#as well on start to simpify some things
signal update()

#this is for the ui to ref. it should be set before the start event
#so a start_dialog() function may be needed to make this easier
var show_cancel:bool = true

#the orignal unparced string. may not be needed
#since could use text_pages (and rebind it)
var source_text : String :
	set(value):
		if value != source_text:
			text_pages = value.split("/p")
		source_text = value
#the parce text to display
var display_text : String
#the string, split into pages. (note: make sure text size, scaling, and 
#such is take care of. ideally the pages could be parce into subpages/scrolling)
var text_pages : PackedStringArray
#the current paged being viewed
var page_index : int = 0
#this holds data used to format the string
#it is more for numbers and things that do not 
#need translation. It may add translation keys,
#but would need to be parced to convert
var format_data : Dictionary

#need to hook these up with the action
#then make sure the ui is notified of their change
var speaker_name : String
var speaker_image : Texture2D

var tts_voice_id : int = 0
var tts_voice_pitch : float = 1.0

#will allow this to hold ref to action
#as callables. options and input would also
#be handled, but as other var
var cancel_task : Callable

var accept_task : Callable

static func get_default_instance()-> State:
	return load('uid://ckldc286fg63p')

func clear_tasks() -> void:
	cancel_task = func():pass
	accept_task = func():pass
#Note not sure if this should be in reset state
#also not sure how reset state will treat defaults
#or if it will event touch properties
#so using clear_state for now untill I feel like testing it
func clear_state() -> void:
	show_cancel = true
	source_text = ''
	display_text = ''
	text_pages.clear()
	page_index = 0
	format_data.clear()
	speaker_name = ''
	speaker_image = null
	tts_voice_id = 0
	tts_voice_pitch = 1.0
	clear_tasks()
