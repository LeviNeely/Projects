extends Button

func _on_pressed():
	if self.text == "Delete":
		ButtonDelete.play()
	else:
		ButtonClick.play()

func _on_mouse_entered():
	ButtonHover.play()
