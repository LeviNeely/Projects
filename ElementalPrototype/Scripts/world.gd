extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://Scenes/player.tscn")

# Variables to modify the boid variables
@export var max_speed: float = 10.0
@export var cohesion_weight: float = 1.0
@export var min_distance: float = 1.0
@export var alignment_weight: float = 1.0
@export var separation_weight: float = 1.0
@export var goal_min_distance: float = 0.0
@export var goal_weight: float = 1.0

# An array to hold all the current boids
var all_boids: Array = []

# The player object
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.position = Vector2(500, 250)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for orb in player.orbs:
		for boid in orb.boids:
			if boid is Projectile:
				if boid.max_speed != max_speed:
					boid.max_speed = max_speed
				if boid.cohesion_weight != cohesion_weight:
					boid.cohesion_weight = cohesion_weight
				if boid.min_distance != min_distance:
					boid.min_distance = min_distance
				if boid.alignment_weight != alignment_weight:
					boid.alignment_weight = alignment_weight
				if boid.separation_weight != separation_weight:
					boid.separation_weight = separation_weight
				if boid.goal_min_distance != goal_min_distance:
					boid.goal_min_distance = goal_min_distance
				if boid.goal_weight != goal_weight:
					boid.goal_weight = goal_weight
