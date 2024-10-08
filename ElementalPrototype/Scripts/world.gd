extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://Scenes/player.tscn")

# The player object
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.position = Vector2(500, 250)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
