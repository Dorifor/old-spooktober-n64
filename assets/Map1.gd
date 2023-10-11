extends Node3D

@onready var main_menu = $MainMenu/CanvasLayer
@onready var adress_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AdressEntry
@onready var root = $"."

const Player = preload("res://assets/player/Player.tscn")

func _ready():
	await get_tree().process_frame
	for player in Globals.PLAYER_DATA.keys():
		add_player(player)
		print(player)
		
func add_player(peer_id):
	if not is_multiplayer_authority(): return
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)

