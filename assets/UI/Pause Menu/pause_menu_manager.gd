extends Control

func _on_horizontal_slider_value_changed(value):
	print(value)


func _on_vertical_slider_value_changed(value):
	print(value)


func _on_volume_slider_value_changed(value):
	print(value)


func _on_return_button_pressed():
	print("RETURN")


func _on_quit_button_pressed():
	get_tree().quit()
