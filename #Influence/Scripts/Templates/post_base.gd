class_name BasePost

extends PanelContainer

@onready var image: TextureRect = %Image
@onready var text: Label = %Text
@onready var cost: Label = %Cost
@onready var shader: ShaderMaterial = preload("res://Assets/Shaders/new_shader_material.tres")
@onready var save_shader: ShaderMaterial = preload("res://Assets/Shaders/saved_post.tres")
@onready var check_box: CheckBox = %CheckBox

var viral: bool = false

#For calculating cost
var price_multiplier: float

#Percentages for increasing money, followers, and sponsors
var money_multiplier: float
var follower_multiplier: float
var sponsor_multiplier: float

#Percentages for increasing chances
var sponsor_chance_multiplier: float
var viral_chance_multiplier: float
var rareness_chance_multiplier: float

#Potential multipliers
var multiplier: float

func _ready() -> void:
	pass

func _process(_delta) -> void:
	pass

func play() -> void:
	pass

func select() -> void:
	pass
