extends CheckBox

@onready var shader: ShaderMaterial = preload("res://Assets/Shaders/saved_post.tres")

var parent: Node
var image: TextureRect

func _on_pressed() -> void:
	parent = get_parent()
	parent = parent.get_parent()
	parent = parent.get_parent()
	parent = parent.get_parent()
	image = parent.find_child("Image")
	if not self.button_pressed:
		parent.material = null
		image.material = null
		remove_from_saved()
	else:
		parent.material = shader
		image.material = shader
		add_to_saved()

func remove_from_saved() -> void:
	var index: int = 0
	for path in TurnData.saved_posts:
		if path == parent.scene_file_path:
			TurnData.saved_posts[index] = null
		index += 1

func add_to_saved() -> void:
	var index: int = 0
	for path in TurnData.saved_posts:
		if path == null:
			TurnData.saved_posts[index] = parent.scene_file_path
			break
		index += 1
