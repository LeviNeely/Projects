extends Node2D

class_name Orb

const NUM_BOIDS: int = 10

# Assignable variables
@export var gravitational_center: Node2D
@export var rotation_speed: float = 0.5 # This is in radians per second
@export var orbit_radius: float = 150.0 # This is the radius tof the path the orb will travel around the player
@export var travel_speed: float = 50.0

# On ready variables

# Other variables
var player_node: Node2D
var orb_index: int = 0
var total_orbs: int = 1
var angle_offset: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if not gravitational_center:
		gravitational_center = get_parent()
	if gravitational_center is Player:
		player_node = gravitational_center
	else:
		player_node = null
	
	# Temporary projectile spawning
	for i in range(NUM_BOIDS):
		var projectile: Projectile = preload("res://Scenes/projectile.tscn").instantiate()
		add_child(projectile)
		projectile.position = Vector2(randf_range((position.x - 50.0), (position.x + 50.0)), randf_range((position.y - 50.0), (position.y + 50.0)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player_node:
		var current_time = Time.get_ticks_msec() / 1000.0
		var angle = current_time * rotation_speed + angle_offset
		var orb_position = player_node.global_position + Vector2(cos(angle), sin(angle)) * orbit_radius
		global_position = orb_position

# A way to dynamically change the index of the orb and total number of orbs
func set_index(index: int, total: int) -> void:
	orb_index = index
	total_orbs = total
	angle_offset = (PI * 2 * orb_index) / total_orbs

# A function to reassign the gravitational center of the orb
func set_gravitational_center(new_center: Node2D) -> void:
	gravitational_center = new_center
