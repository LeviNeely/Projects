extends Control

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	Music.play_menu_theme()
	get_tree().change_scene_to_file("res://Scenes/Screens/start_screen.tscn")
