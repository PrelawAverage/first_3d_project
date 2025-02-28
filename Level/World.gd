class_name World extends Node3D

@onready var sun = $Environment/DirectionalLight3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sun.rotation_degrees.x += delta / 4 # Super basic day and night cycle.
