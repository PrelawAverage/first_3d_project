# This script is used to control the player's movement, health, and other attributes.

class_name Player extends CharacterBody3D

# Grabbing Player Nodes in scene
@onready var head: CameraHandler = $Head

@onready var standing_collision_shape: CollisionShape3D = $"StandingCollisionShape"
@onready var crouching_collision_shape: CollisionShape3D = $"CrouchingCollisionShape" 
@onready var player_height_ray_cast: RayCast3D = $"PlayerHeightRayCast" # Used to detect whether the players hitbox is being obstructed

@onready var player_hud: Control = $"PlayerHUD"
@onready var hurt_overlay: TextureRect = $"PlayerHUD/HurtOverlay"
@onready var feet_audio_stream_player: AudioStreamPlayer3D = $"FeetAudioStreamPlayer"

var head_height: float = 1.6
var crouching_offset: float = 0.6 # offset 

@export_subgroup("Attributes")
@export var health: int = 100
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var sneak_speed: float = 2.0
@export var crouch_speed: float = 3.0
@export var jump_power: float = 5.2
@export var fall_damage_threhold: float = -10.0
var was_in_air : bool = false
var speed

@export_subgroup("Settings")
@export var sensitivity: float = 0.002

# Used to detect what the player is doing, will be very useful in the future.
var moving : bool = false
var sprinting : bool = false
var sneaking : bool = false
var crouching : bool = false

# Menu
var isShowingUI : bool = false

var pause_menu: PackedScene = preload("res://UI/Pause/PauseMenu.tscn")

var mouse_delta: Vector2 = Vector2.ZERO

func _ready():
	head.position.y = head_height
	crouching_collision_shape.disabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Makes the mouse disapear 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if !isShowingUI:
			add_child(PauseMenu.new_pause(self))

func _physics_process(delta):
	_handle_movement(delta)

	# Play step sound at the peak of the x-axis bobbing (when x changes from positive to negative)
	if !sneaking and !crouching:
		if (head.previous_camera_pos.x > 0 and position.x <= 0) or (head.position.x < 0 and position.x >= 0):
			feet_audio_stream_player.play()
	head.previous_camera_pos.x = position.x

func _handle_movement(delta) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power
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
		_on_landed()
	was_in_air = !is_on_floor()

func _canMove() -> bool:
	return !isShowingUI

func _on_landed():
	print("Landed")
	feet_audio_stream_player.play()
