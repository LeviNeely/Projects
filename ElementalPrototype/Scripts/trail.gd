class_name Trail
extends Line2D

# Set constants
const MAX_POINTS: int = 750
# Ready Curve
@onready var curve := Curve2D.new()
# Setup gradient for the trail color
#var gradient = Gradient.new()
# Set gradient color to match parent
func _ready() -> void:
	# attempting to get color from parent - does not work
	var parent_color = get_parent().get("modulate")
	# go from that color to lighter version of it - manually set color to red because I can't get color from parent properly
	gradient.set_color(0, Color.RED)
	gradient.set_color(1, Color.RED.lightened(0.6))

func _process(delta: float) -> void:
	# Add the orb's current position to the curve
	curve.add_point(get_parent().position)
	# Remove the oldest point if exceeds max points
	if curve.get_baked_points().size() > MAX_POINTS: 
		curve.remove_point(0)
	# Update Line2D points to follow the curve
	points = curve.get_baked_points()
	
func stop() -> void:
	set_process(false)
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 3.0)
	await tw.finished
	queue_free()
	
static func create() -> Trail:
	var scn = preload("res://Scenes/trail.tscn")
	return scn.instantiate()
	
# Export variables
#@export var MAX_LENGTH: int = 50


## Other variables
#var parent: Node2D
#var queue: Array[Vector2] = []
#
## Called when the node enters the scene tree for the first time
#func _ready():
	#parent = get_parent()
#
## Called every frame
#func _process(_delta):
	## Get the parent object's position
	#var pos = get_parent_position()
	## Then add it to the FIFO queue
	#queue.push_front(pos)
	## We also want to control how long the trail is in general, so we can modify that here
	#if queue.size() > MAX_LENGTH:
		#queue.pop_back()
	## Then we redraw
	#clear_points()
	## And add the current points
	#for point in queue:
		#add_point(point)
#
## Function to get the parent's position
#func get_parent_position() -> Vector2:
	#return get_parent().position
