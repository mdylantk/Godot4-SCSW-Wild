class_name Dialog_Script_Resource extends Resource

#this is the text that will be used if no other logic or 
#varibles are provided
@export_multiline var default_script : String

#NOTE and TODO: add a dictoranry to be populated by varibles
#this should be pass on to dialog_data and should contain varibles
#related to the target
#NOTE: may need to pass something to use as a way to format the text
#since format by itself may not beable to dynamicly format. would need to run test on
#dynamicly formating

#this represent an array of strings used for dialog
#instead of being just an array, this will tie logic to it
#but provifing a get_dialog_script function that will return
#an array (or if decided it work better) a dictionary

#a possible option for this is parcing a json, but the issue is
#acessing the json from the build data
#a json would be a dictionary of key and array of data
#the data is ideally just an array of strings or and id that link localation to it
#but could contain an array of random options as well.
#the array of data is for random picks 
# it may be a nested mess, but may be the easist way to simulate random and
#static dialog choices
#data fetching approch still need to be decided upon. need to extract
#var from the string and load them, but some may be pass nativly since it be related
#to the characters and have defaults if non is provided (aka pronouns and name)

#NOTE: the biggest issue if multible choice is added. the json key system may help
#but may be hard to read if it start to branch a lot
#I mean the keys be the key base and choice id. 
#like: "chat:+greet:rumors" which + means positive so a "chat:greet:rumors" 
#filter check may be needed to find a default chat if a positive chat greeting is 
#not aviable. also could try remaking the system with mood in mind, but may be best
#just adding prefix/suffix randomly to state a mood and maybe mix with a more simplify
#key look up like :"+chat:greet:rumors" then only the first need to be check and


#TODO and NOTE: in dialog data or dialog gui, add a way to line split the
#text. manually spliting is nice for looks, but is extra work. also is not scalable
#with changes in front size 

#get the script as a single string
func get_dialog_text(key="default"):#decide if a parameter is needed.
	#this will return something for the dialog data to use
	#either an array of strings or one large string.
	#array would be nice, but then this would need 
	#to know how to spilt it if splitting is needed
	#NOTE: SplitContainer may help? then just need a full
	#string from data provided for this
	return default_script

#Get the script as an array of strings
func get_dialog_script(key="default"):
	return default_script.split("\n")
