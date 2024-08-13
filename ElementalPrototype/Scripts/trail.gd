extends Line2D

class_name Trail

# Export variables
@export var MAX_LENGTH: int = 50

# Other variables
var parent: Node2D
var queue: Array[Vector2] = []

# Called when the node enters the scene tree for the first time
func _ready():
	parent = get_parent()

# Called every frame
func _process(_delta):
	# Get the parent object's position
	var pos = get_parent_position()
	# Then add it to the FIFO queue
	queue.push_front(pos)
	# We also want to control how long the trail is in general, so we can modify that here
	if queue.size() > MAX_LENGTH:
		queue.pop_back()
	# Then we redraw
	clear_points()
	# And add the current points
	for point in queue:
		add_point(point)

# Function to get the parent's position
func get_parent_position() -> Vector2:
	return get_parent().position
