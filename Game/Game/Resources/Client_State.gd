class_name Client_State extends State
signal updated()

#currently storing client data in a config file for now
#Since it faster than declaring them here and handling it
#like the other states
#may delare each value here in the future for readiblity
#and could use setters/getters to add directly to reduce loops on save
#and extra memory(? might still reserve the space in memory)
var config_file = ConfigFile.new()
