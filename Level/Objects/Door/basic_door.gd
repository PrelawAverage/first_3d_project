class_name Interactable extends StaticBody3D

@onready var animation_tree: AnimationTree = $"../../AnimationTree"
@onready var audio_player: AudioStreamPlayer3D = $"../Handle/AudioStreamPlayer3D"
@onready var timer: Timer = $"../../Timer"

@export var open_sound: AudioStream
@export var close_sound: AudioStream

var State : bool = false
var playback = null

func _ready() -> void:
	playback = animation_tree.get("parameters/playback")

func interact():
	State = !State
	if State:
		playback.travel("open")
		audio_player.stream = open_sound
		audio_player.play()
	else:
		timer.start(animation_tree.get_animation("close").length)
		playback.travel("close")

func _on_timer_timeout() -> void:
	audio_player.stream = close_sound
	audio_player.play()
