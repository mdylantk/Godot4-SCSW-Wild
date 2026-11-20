##this holds all global objects realted to the current game session
class_name Game extends RefCounted
#Note: this should not handle game logic for that is the game handler responsibility
#this is isolated from it due to a personal rule and this is not part of the game state
#since this will hold ref to the game state (also another personal rule to not know thy self)
#it also shouldnot be nessary and it mostly a debugging tool plus a way for implementions 
#to easly acess some resources if left undefined instread of a string path

#NOTE: states shoul;d exist first. loading states will mean updating the exisiting state
#NOTE: may not make sure the states are the same here and in the handler, but the game
#handler should set these first
static var game_state : Game_State = load("uid://cnbeqfpaumxj3")
static var client_state : Client_State = load("uid://bnvrjjacwa30l")
static var player_state : Player_State = load("uid://c67c2fehtuhni")
static var world_state : World_State = load("uid://b047ftosxvj7p")
static var ui_state : UI_State = load("uid://dkc6l4f8ve4t5")
static var dialog_state : Dialog_State = load("uid://ckldc286fg63p")
