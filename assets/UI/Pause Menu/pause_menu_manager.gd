extends Control

@export var player: CharacterBody3D

func _on_horizontal_slider_value_changed(value):
	Globals.HORIZONTAL_SENSIBILITY_VALUE = value


func _on_vertical_slider_value_changed(value):
	Globals.VERTICAL_SENSIBILITY_VALUE = value


func _on_volume_slider_value_changed(value):
	Globals.VOLUME_VALUE = value
	# TODO: Probablement changer le volume des sons jsp ou si c'est deja centralise dans Godot


func _on_return_button_pressed():
	visible = false
	Globals.IS_GAME_PAUSED = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false


func _on_quit_button_pressed():
	get_tree().quit()
