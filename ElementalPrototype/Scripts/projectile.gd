extends Polygon2D

class_name Projectile

# Assignable variables
@export var gravitational_center: Node2D
@export var max_speed: float = 8.0
@export var cohesion_weight: float = 1.0
@export var min_distance: float = 0.00001
@export var alignment_weight: float = 1.0
@export var separation_weight: float = 1000.0
@export var goal_min_distance: float = 0.0
@export var goal_weight: float = 0.000000001

# Other variables
var other_projectile_list: Array[Projectile] = []
var velocity: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not gravitational_center:
		gravitational_center = get_parent()
	velocity = Vector2(randi_range(-50, 50), randi_range(-50, 50))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	cohesion()
	alignment()
	separation()
	goal()
	limit_speed()
	global_position += (velocity * max_speed * delta)

# Function to limit the speed so things do not get out of hand
func limit_speed() -> void:
	var speed = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
	if speed > max_speed:
		var scale_factor = max_speed / speed
		velocity *= scale_factor

# Function to steer the boid towards the "gravitational center"
func goal() -> void:
	# We don't need to do anything if there isn't a graviational center
	if not gravitational_center:
		return
	
	# Calculate the vector to the gravitational center
	var to_center: Vector2 = gravitational_center.global_position - global_position
	var distance: float = to_center.length()
	
	# Calculate the desired distance to start circling
	var desired_distance: float = min_distance + 50.0 #adjust if needed
	
	# If within the desired distance, calculate tangential velocity
	if distance < desired_distance:
		#Normalize the vector to the center
		var normalized_to_center: Vector2 = to_center.normalized()
		
		# Calculate tangential velocity vector (rotate 90 degrees)
		var tangential_velocity: Vector2 = Vector2(-normalized_to_center.y, normalized_to_center.x)
		
		# Apply tangential velocity
		velocity += tangential_velocity * max_speed * 0.1
	# Otherwise, steer towards the player
	else:
		velocity += (to_center / goal_weight)

# Function used to ensure the boids do not collide with other boids
func separation() -> void:
	# If there aren't any other boids, we don't have to do anything
	if other_projectile_list.size() == 0:
		return
	
	# We also check to see if there is a goal and if we are too close to it
	if gravitational_center:
		if distance_between(gravitational_center) < goal_min_distance:
			var goal_separation_velocity: Vector2 = Vector2.ZERO
			goal_separation_velocity += global_position - gravitational_center.global_position
			velocity += (goal_separation_velocity / separation_weight)
	
	# Otherwise, we figure out if we need to separate from other boids and by how much
	var separation_velocity: Vector2 = Vector2.ZERO
	for boid in other_projectile_list:
		if distance_between(boid) < min_distance:
			separation_velocity += global_position - boid.global_position
	velocity += (separation_velocity / separation_weight)

# Function to calculate the distance between two boids
func distance_between(projectile: Node2D) -> float:
	# We don't want to calculate distance between ourself
	if self == projectile:
		return (min_distance + 1000.0)
	
	# Otherwise, calculate and return the distance
	var dist: Vector2 = global_position - projectile.global_position
	return sqrt(pow(dist.x, 2) + pow(dist.y, 2))

# Function used to keep the boids in alignment with the others
func alignment() -> void:
	# If there aren't any other boids, we don't have to do anything
	if other_projectile_list.size() == 0:
		return
	
	# Otherwise we need to calculate the average velocity of other void within our field of vision
	var average_velocity: Vector2 = Vector2.ZERO
	for boid in other_projectile_list:
		average_velocity += boid.velocity
	average_velocity /= other_projectile_list.size()
	
	# Then we update our own velocity to better align with the others
	velocity += (average_velocity / alignment_weight)

# Function to determine the average velocity of the boids within our field of vision
func cohesion() -> void:
	# We don't need to worry about other boids if there are none
	if other_projectile_list.size() == 0:
		return
	
	# Otherwise, we calculate the center of mass
	var center: Vector2 = center_of_mass()
	
	# And then we calculate the change in our velocity to stick to the group
	var velocity_change: Vector2 = center - global_position
	
	# Finally, we update our velocity
	velocity += (velocity_change / cohesion_weight)

func center_of_mass() -> Vector2:
	# If the list is empty, we just return zero
	if other_projectile_list.size() == 0:
		return Vector2.ZERO
	
	# Otherwise, we calculate the center of mass for the list
	var center: Vector2 = Vector2.ZERO
	for boid in other_projectile_list:
		center += boid.global_position
	center /= other_projectile_list.size()
	return center

func add_projectile_to_list(body: Node2D) -> void:
	if body is Projectile:
		other_projectile_list.append(body)

func remove_projectile_to_list(body: Node2D) -> void:
	if body is Projectile:
		var index = other_projectile_list.find(body)
		if index >= 0:
			other_projectile_list.remove_at(index)

func _on_area_2d_body_entered(body):
	add_projectile_to_list(body)

func _on_area_2d_body_exited(body):
	remove_projectile_to_list(body)
