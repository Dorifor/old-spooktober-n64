extends Node

@onready var main_menu = $MainMenu/CanvasLayer
@onready var adress_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AdressEntry
@onready var root = $"."

const Map = preload("res://assets/main.tscn")
const Player = preload("res://assets/player/Player.tscn")
const PORT = 9999
var peer = ENetMultiplayerPeer.new()

func _on_host_button_pressed():
	main_menu.hide()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	$DebugOnline/IDPlayer.text = str(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(add_player)
	add_player(multiplayer.get_unique_id())

func _on_join_button_pressed():
	main_menu.hide()
	
	peer.create_client("localhost",PORT)
	multiplayer.multiplayer_peer = peer
	$DebugOnline/IDPlayer.text = str(multiplayer.get_unique_id())
	add_player(multiplayer.get_unique_id())

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	print(player.name)
	add_child(player)
