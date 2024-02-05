extends Button

const rewards: Array[String] = [
	"res://Scenes/Rewards/follower_reward.tscn",
	"res://Scenes/Rewards/money_reward.tscn",
	"res://Scenes/Rewards/sponsor_reward.tscn"
]

func _on_pressed():
	if self.text == "Delete Post":
		ButtonDelete.play()
	else:
		ButtonClick.play()
	var parent = get_parent()
	parent = parent.get_parent()
	parent = parent.get_parent()
	if parent.scene_file_path not in rewards:
		var image = parent.find_child("Image")
		var check_box: CheckBox = parent.find_child("CheckBox")
		if parent.viral:
			parent.material = load("res://Assets/Shaders/new_shader_material.tres")
			image.material = null
			if check_box.button_pressed:
				check_box.button_pressed = false
		else:
			parent.material = null
			image.material = null
			if check_box.button_pressed:
				check_box.button_pressed = false
		check_box._on_pressed()
		var vbox: VBoxContainer = parent.find_child("Save")
		vbox.visible = false

func _on_mouse_entered():
	ButtonHover.play()
