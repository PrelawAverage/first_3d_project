# This script is used to control the player's movement, health, and other attributes.
class_name GravityPlayer extends RigidBody3D

@onready var head: Node3D = $Head

# Grabbing Player Nodes in scene
var rotation_speed := 8.0
var move_direction : Vector3
var last_strong_direction := Vector3.FORWARD
var gravity := Vector3.DOWN
var jump_strength := 5.2
var walk_speed := 2.0
var up_direction := Vector3.ZERO
var max_walkable_angle: float = .45

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Makes the mouse disapear
	contact_monitor = true # Make sure this object reports contacts with other objects
	max_contacts_reported = 1

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	gravity = state.total_gravity
	if gravity.length() < 0.001:
		gravity = Vector3.DOWN  # Fallback to a default gravity
	
	gravity = gravity.normalized() # Normalize safely
	var delta := state.step # Get delta time
	
	# Get movement input
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")

	# Compute movement directions
	var forward := -head.global_transform.basis.z
	var right := head.global_transform.basis.x

	# Ensure `forward` and `right` are valid before normalizing
	var projected_forward := forward - forward.project(gravity)
	if projected_forward.length() < 0.001:
		projected_forward = Vector3.FORWARD  # Fallback if too small
	else:
		projected_forward = projected_forward.normalized()

	var projected_right := right - right.project(gravity)
	if projected_right.length() < 0.001:
		projected_right = Vector3.RIGHT  # Fallback if too small
	else:
		projected_right = projected_right.normalized()

	# Calculate movement direction
	var move_direction := (input_dir.x * projected_right + input_dir.y * projected_forward).normalized() if input_dir.length() > 0.001 else Vector3.ZERO

	# Apply movement
	if is_on_floor(state):
		var target_velocity := move_direction * walk_speed
		linear_velocity = linear_velocity.lerp(target_velocity, delta * 7.0)
	else:
		var target_velocity := move_direction * walk_speed
		linear_velocity = linear_velocity.lerp(target_velocity, delta)

	orient_up(delta)

	# Handle jumping
	if is_on_floor(state) and Input.is_action_just_pressed("jump"):
		apply_central_impulse(-gravity * jump_strength)


func orient_up(delta: float) -> void:
	if gravity.length() > 0.001:
		var up_dir := -gravity.normalized()  # Ensure it's normalized and facing "up"
		var forward_dir := (transform.basis.z - transform.basis.z.project(up_dir)).normalized()  # Remove any tilt from gravity
		var right_dir := up_dir.cross(forward_dir).normalized()  # Recalculate right direction
		var target_basis := Basis(right_dir, up_dir, forward_dir)  # Construct correct orientation
		transform.basis = transform.basis.slerp(target_basis, delta * 5.0)  # Smoothly rotate

func is_on_floor(state: PhysicsDirectBodyState3D) -> bool:
	for contact in state.get_contact_count():
		var contact_normal = state.get_contact_local_normal(contact)
		if contact_normal.dot(-gravity) > 0.5:
			return true
	return false
