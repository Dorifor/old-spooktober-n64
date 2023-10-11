extends Node3D

@onready var main_menu = $MainMenu/CanvasLayer
@onready var adress_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AdressEntry
@onready var root = $"."

const Player = preload("res://assets/player/Player.tscn")

func _ready():
	for player in Globals.PLAYER_DATA.keys():
		add_player(player)
		
func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
