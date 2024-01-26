extends Button

func _on_pressed():
	if self.text == "Delete Post":
		ButtonDelete.play()
	else:
		ButtonClick.play()

func _on_mouse_entered():
	ButtonHover.play()
