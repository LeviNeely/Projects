extends CharacterBody2D

class_name Player

# Export variables
@export var speed: float = 300.0

# Other variables
var total_orbs: int = 3
var orbs: Array = []

func _ready() -> void:
	spawn_orbs()

func _physics_process(_delta) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

# Function to spawn orbs
func spawn_orbs() -> void:
	for i in range(total_orbs):
		var orb = preload("res://Scenes/orb.tscn").instantiate()
		add_child(orb)
		orbs.append(orb)
		orb.set_index(i, total_orbs)

# Function to set total_orbs
func set_total_orbs(new_total: int) -> void:
	total_orbs = new_total
	update_orbs()

# Function to update orbs
func update_orbs() -> void:
	# Remove excess orbs
	while orbs.size() > total_orbs:
		var orb = orbs.pop_back()
		orb.queue_free()
	# Add new orbs if necessary
	while orbs.size() < total_orbs:
		var orb = preload("res://Scenes/orb.tscn").instantiate()
		add_child(orb)
		orbs.append(orb)
		orb.set_index(orbs.size() - 1, total_orbs)
	# Update indices of existing orbs
	for i in range(orbs.size()):
		orbs[i].set_index(i, total_orbs)
