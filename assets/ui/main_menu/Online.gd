extends Node

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
var DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

@onready var online_menu = $Menu/CanvasLayer
@onready var lobby = $lobby/CanvasLayer
@onready var AdressIP = $Menu/CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AdressEntry

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

var timeout_timer
# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Default"}

var players_loaded = 0



func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_join_button_pressed(address = "localhost"):
	if $Menu/CanvasLayer/MainMenu/MarginContainer/VBoxContainer/PseudoEntry.text == "":
		return
	player_info = {"name": $Menu/CanvasLayer/MainMenu/MarginContainer/VBoxContainer/PseudoEntry.text}
	online_menu.hide()
	lobby.show()
	$lobby/CanvasLayer/Start_game.hide()
	DEFAULT_SERVER_IP = AdressIP.text
	address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	
	print (error)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	print(players)


func _on_host_button_pressed():
	if $Menu/CanvasLayer/MainMenu/MarginContainer/VBoxContainer/PseudoEntry.text == "":
		return
	player_info = {"name": $Menu/CanvasLayer/MainMenu/MarginContainer/VBoxContainer/PseudoEntry.text}
	online_menu.hide()
	lobby.show()
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	players[1] = player_info
	player_connected.emit(1, player_info)
	print(players)


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)

@rpc("any_peer", "call_local", "reliable")
func update_list():
	$"lobby/CanvasLayer/Player List".clear()
	for player in players.values():
		$"lobby/CanvasLayer/Player List".add_item(player["name"], null, false)

		
# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0


func _process(delta):
	update_list()
	
# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	players.erase(id)
	#player_disconnected.emit(id)
 
func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	get_tree().change_scene_to_file("res://assets/ui/main_menu/main_menu.tscn")


func _on_start_game_pressed():
		start_game()  # Appel de la RPC start_game sur le serveur
		rpc("start_game")  # Appel de la RPC start_game sur les clients
	
	
@rpc("any_peer", "call_remote", "reliable")
func start_game():
	Globals.PLAYER_NUMBER = players.size()
	Globals.PLAYER_DATA = players
	Globals.ID_CURRENTPLAYER = multiplayer.get_unique_id()
	print(players.size())
	get_tree().change_scene_to_file("res://assets/main.tscn")


func _on_timer_timeout():
	
	return
