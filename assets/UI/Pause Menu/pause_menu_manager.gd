extends Control

@export var player: CharacterBody3D

func _on_horizontal_slider_value_changed(value):
	print(value)


func _on_vertical_slider_value_changed(value):
	print(value)


func _on_volume_slider_value_changed(value):
	print(value)


func _on_return_button_pressed():
	visible = false
	player.paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_quit_button_pressed():
	get_tree().quit()
