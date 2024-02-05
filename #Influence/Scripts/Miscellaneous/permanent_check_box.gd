extends CheckBox

@onready var shader: ShaderMaterial = preload("res://Assets/Shaders/saved_post.tres")
@onready var button: Button = %Button
@onready var save: VBoxContainer = %Save

var parent: Node
var image: TextureRect

func _ready() -> void:
	if button.text == "Delete":
		save.visible = false

func _on_pressed():
	parent = get_parent()
	parent = parent.get_parent()
	parent = parent.get_parent()
	parent = parent.get_parent()
	if not self.button_pressed:
		parent.material = null
		remove_from_saved()
	else:
		parent.material = shader
		add_to_saved()

func remove_from_saved() -> void:
	var index: int = 0
	for path in TurnData.saved_permanents:
		if path == parent.scene_file_path:
			TurnData.saved_permanents[index] = null
		index += 1

func add_to_saved() -> void:
	var index: int = 0
	for path in TurnData.saved_permanents:
		if path == null:
			TurnData.saved_permanents[index] = parent.scene_file_path
			break
		index += 1
