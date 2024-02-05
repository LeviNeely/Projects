extends Button

func _on_pressed():
	ButtonClick.play()
	GlobalMethods.emit_signal("proceed")
	var parent = self.get_parent()
	parent = parent.get_parent()
	parent = parent.get_parent()
	parent.queue_free()

func _on_mouse_entered():
	ButtonHover.play()
