extends Control

@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var back_ground: TextureRect = %BackGround
@onready var backgrounds: Array[String] = [
	"res://Assets/Backgrounds/Civilians.png",
	"res://Assets/Backgrounds/Displacement.png",
	"res://Assets/Backgrounds/Culture.png",
	"res://Assets/Backgrounds/Apartheid.png",
	"res://Assets/Backgrounds/Genocide.png"
]
@onready var educational_posts: Array[String] = [
	"res://Scenes/Education/education_1.tscn",
	"res://Scenes/Education/education_2.tscn",
	"res://Scenes/Education/education_3.tscn",
	"res://Scenes/Education/education_4.tscn",
	"res://Scenes/Education/education_5.tscn"
]

func _ready() -> void:
	var image = load(backgrounds[TurnData.num_education_posts_read])
	back_ground.texture = image
	await get_tree().create_timer(3).timeout
	var post = load(educational_posts[TurnData.num_education_posts_read])
	canvas_layer.add_child(post.instantiate())
