extends Button

func _on_pressed():
	if self.text == "Delete":
		ButtonDelete.play()
	else:
		ButtonClick.play()
	var parent = get_parent()
	parent = parent.get_parent()
	parent = parent.get_parent()
	var check_box: CheckBox = parent.find_child("CheckBox")
	parent.material = null
	if check_box.button_pressed:
		check_box.button_pressed = false
	check_box._on_pressed()

func _on_mouse_entered():
	ButtonHover.play()
