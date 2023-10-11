extends Control

@onready var main_menu = $CanvasLayer/MainMenu
@onready var adress_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AdressEntry
@onready var root = $"."

const Map = preload("res://assets/main.tscn")
const Player = preload("res://assets/player/Player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()  

func _on_host_button_pressed():
	var level = root.get_node("CanvasLayer")
	root.remove_child(level)
	level.call_deferred("free")
	var next_level_resource = load("res://assets/main.tscn")
	var next_level = next_level_resource.instantiate()
	root.add_child(next_level)
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())

func _on_join_button_pressed():
	var level = root.get_node("CanvasLayer")
	root.remove_child(level)
	level.call_deferred("free")
	enet_peer.create_client("localhost",PORT)
	multiplayer.multiplayer_peer = enet_peer
	add_player(multiplayer.get_unique_id())

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	print(player.name)
	add_child(player)
