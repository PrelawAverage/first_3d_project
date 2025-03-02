# This script is used to control the player's movement, health, and other attributes.
class_name Player extends CharacterBody3D

# Grabbing Player Nodes in scene
@onready var head: CameraHandler = $Head
@onready var feet_audio_stream_player: AudioStreamPlayer3D = $FeetAudioStreamPlayer
@onready var standing_collision_shape: CollisionShape3D = $"StandingCollisionShape"
@onready var crouching_collision_shape: CollisionShape3D = $"CrouchingCollisionShape" 
@onready var player_height_ray_cast: RayCast3D = $"PlayerHeightRayCast" # Used to detect whether the players hitbox is being obstructed
@onready var player_hud: PlayerHUD = $"Player HUD"

var head_height: float = 1.6
var crouching_offset: float = 0.6 # offset 

var max_health: float = 100
var health: float
var max_time_before_health_regen: float = 5.0
var time_before_health_regen: float = 0.0
var regen_rate: float = 1.0  # How much health regenerates per second

var walk_speed: float = 5.0
var sprint_speed: float = 8.0
var sneak_speed: float = 2.0
var crouch_speed: float = 3.0
var jump_power: float = 5.2
var fall_damage_threhold: float = 10.0
var was_in_air : bool = false
var speed

var sensitivity: float = 0.002

# Used to detect what the player is doing, will be very useful in the future.
var moving : bool = false
var sprinting : bool = false
var sneaking : bool = false
var crouching : bool = false

# Menu
var isShowingUI : bool = false

var pause_menu: PackedScene = preload("res://UI/Pause/PauseMenu.tscn")

var mouse_delta: Vector2 = Vector2.ZERO

var previous_camera_pos_x: float = 0.0  # Track previous x position
var previous_y_velocity: float = 0.0  # Stores the previous Y velocity

func _ready():
	health = max_health
	head.position.y = head_height
	crouching_collision_shape.disabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Makes the mouse disapear 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if !isShowingUI:
			add_child(PauseMenu.new_pause(self))

func _physics_process(delta):
	_handle_movement(delta)
	_play_step_sound()

	# Check if we need to reduce the cooldown timer
	if time_before_health_regen > 0:
		time_before_health_regen -= delta  # Reduce the timer over time
	# Regenerate health once the cooldown is over
	if time_before_health_regen <= 0 and health < max_health:
		regenerate_health(delta) # Regenerate health after the cooldown

func _handle_movement(delta) -> void:
	
	# This is to make sure the player's up direction is always aligned with the gravity zone it is in.
	up_direction = -get_gravity().normalized()
	set_up_direction(up_direction)
	
	# Add the gravity based on the current gravity zone
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Jumping based on the gravity zone and if the player is on the floor.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity -= get_gravity().normalized() * jump_power
	# Handle Sprint.
	if Input.is_action_pressed("crouch"):
		crouching = true
		speed = crouch_speed
		crouching_collision_shape.disabled = false
		standing_collision_shape.disabled = true
		head.position.y = lerp(head.position.y, head_height - crouching_offset, delta * 10.0)
	elif !player_height_ray_cast.is_colliding():
		crouching = false
		crouching_collision_shape.disabled = true
		standing_collision_shape.disabled = false
		head.position.y = lerp(head.position.y, head_height, delta * 10.0)
		if Input.is_action_pressed("sprint"):
			sprinting = true
			speed = sprint_speed
		elif Input.is_action_pressed("sneak"):
			sneaking = true
			speed = sneak_speed
		else:
			sprinting = false
			sneaking = false
			speed = walk_speed
	# Get the input direction and handle the movement/deceleration.
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() if _canMove() else Vector3.ZERO
	print(direction)
	moving = direction != Vector3.ZERO
	if is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta)
		velocity.z = lerp(velocity.z, direction.z * speed, delta)
	move_and_slide()
	
	# Handle fall damage
	if was_in_air and is_on_floor():
		_on_landed(abs(previous_y_velocity)) # Pass the impact velocity
	was_in_air = !is_on_floor()
	previous_y_velocity = velocity.y # Store the current Y velocity for the next frame

func _canMove() -> bool:
	return !isShowingUI
	
# Designed to be synced with the head bobbing in the CameraHandler script
func _play_step_sound() -> void:
	var cam_pos_x: float = head.pos.x  # Get camera bobbing position
	# Play step sound at the peak of the x-axis bobbing on either side
	if (previous_camera_pos_x > 0 and cam_pos_x <= 0) or (previous_camera_pos_x < 0 and cam_pos_x >= 0):
		feet_audio_stream_player.play()
	previous_camera_pos_x = cam_pos_x  # Update previous position

func _on_landed(fall_velocity: float) -> void:
	feet_audio_stream_player.play()
	if fall_velocity > fall_damage_threhold:
		_deal_damage(int(fall_velocity))
		player_hud._hurt_effect(int(fall_velocity))
	
func _deal_damage(damage: int) -> void:
	time_before_health_regen = max_time_before_health_regen
	health -= damage
	if health <= 0:
		health = 0
		# Player is dead
		print("Player is dead")
		# Add game over screen
		# QueueFree()

# Method to regenerate health after the cooldown
func regenerate_health(delta: float):
	# Make sure regen_rate is 1 to increase health by 1 per second
	health += 1 * delta  # This will increment health by 1 every second
	health = clamp(health, 0, max_health)  # Ensure health does not exceed max_health
