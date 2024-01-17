extends PanelContainer

func _on_button_pressed():
	TurnData.num_education_posts_read += 1
	get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")
