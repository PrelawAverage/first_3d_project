# This script is responsible for handling the camera, including head bobbing, FOV changes, and mouse input.
class_name GravityCameraHandler extends Node3D

@onready var player: GravityPlayer = $".."
@onready var camera_socket: Node3D = $CameraSocket
@onready var camera_3d: Camera3D = $CameraSocket/Camera3D
@onready var feet_audio_stream_player: AudioStreamPlayer3D = $"../FeetAudioStreamPlayer"
@export_category("Camera Utils")
@export var camera_bobbing_frequency: float = 3.2
@export var camera_bobbing_amplitude: float = 0.05
var t_bob: float = 0.0
var pos: Vector3 = Vector3.ZERO
var previous_camera_pos : Vector3 = Vector3.ZERO  # Track previous x position

@export_subgroup("Settings")
@export var sensitivity: float = 0.002

# FOV Changes Variables
const BASE_FOV: float = 75.0
const FOV_CHANGE: float = 1.25
var mouse_delta: Vector2 = Vector2.ZERO

# Ran when the player does anything, at all. Useful to detect things like mouse movements
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_delta += event.relative

func _physics_process(delta):
	# Rotate the camera
	if mouse_delta != Vector2.ZERO:
		rotate_y(-mouse_delta.x * sensitivity)
		camera_socket.rotate_x(-mouse_delta.y * sensitivity)
		camera_socket.rotation_degrees.x = clamp(camera_socket.rotation_degrees.x, -90, 90)
		mouse_delta = Vector2.ZERO
	# FOV Changes
	var velocity_clamped = clamp(player.linear_velocity.length(), 0.5, 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera_3d.fov = lerp(camera_3d.fov, target_fov, delta * 8.0)

func _setHeadbobPosition(time: float) -> Vector3:
	pos = Vector3.ZERO
	pos.y = sin(time * camera_bobbing_frequency) * camera_bobbing_amplitude
	pos.x = cos(time * camera_bobbing_frequency / 2) * camera_bobbing_amplitude
	return pos
