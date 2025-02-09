class_name Base_Action extends Resource

#TODO: decided if this should also have basic getters for data
#like fetching node or enum for identifiers
#may have some types as an array of nodes (target(s) and source(s))
#though usally there only one source and most cases where other are involve
#the tiggering source would handle them...or should
#target may need additional info, though could use array order
#are order of importanice and querry for more info if needed

#also the enum would allow handler,source, targets to be stored in one array
#instead of in the top scope of data. could be called refrences or something
#a class/object/resource could also replace the array, but arrays are ligher


func run(data:Action_Data = null) -> bool:
	return true
