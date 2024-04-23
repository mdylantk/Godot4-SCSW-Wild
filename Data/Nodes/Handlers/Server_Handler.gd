class_name Server_Handler extends Node

@export var address := "127.0.0.1"
@export var port := 8888
@export var max_player := 8 #note 32 may be godot max?

@export var compression := ENetConnection.COMPRESS_RANGE_CODER

var peer:ENetMultiplayerPeer

func _ready() -> void:
	print_debug("I am ready")
	#NOTE: the game may need to handle this or redirect it up top the game
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_connected)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)
	
func on_peer_connected(id):
	print_debug("connection created : " +str(id))
	
func on_peer_disconnected(id):
	print_debug("connection ended : " +str(id))

func on_connected_to_server():
	print_debug("connected to server")
	
func on_connection_failed():
	print_debug("connection_failed")

func host_server():
	print_debug("hosting a server")
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(port,max_player,)
	if error != OK:
		print_debug(error)
		return
	peer.get_host().compress(compression)
	multiplayer.set_multiplayer_peer(peer)

func join_server():
	print_debug("joing a server")
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_client(address,port)
	if error != OK:
		print_debug(error)
		return
	peer.get_host().compress(compression)
	multiplayer.set_multiplayer_peer(peer)
	
#NOTE: disconnect not being called. need an override. a null check maybe
#but also a null set so new connections can exist
#debug
#NOTE: could try to create pear on ready if possible to change host/client
#and server stuff
func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_page_up"):
		if peer != null:
			print_debug("peer already exist.")
		host_server()
	elif event.is_action_pressed("ui_page_down"):
		if peer != null:
			print_debug("peer already exist. closing if a host")
			peer.close()
		join_server()
