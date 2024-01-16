extends Control

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")

func _on_load_game_pressed() -> void:
	pass # Eventually replace this with the load functionality

func _on_options_pressed() -> void:
	pass # Eventually replace this with loading the options screen

func _on_quit_pressed() -> void:
	get_tree().quit()
