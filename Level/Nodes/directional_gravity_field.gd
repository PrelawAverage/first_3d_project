class_name DirectionalGravityField extends Area3D

# Turns on the gravity field
func _ready() -> void:
	set_gravity_space_override_mode(SPACE_OVERRIDE_REPLACE)
	set_process_input(false)

# Updates the gravity field based on the global transforms
func _process(_delta: float) -> void:
	gravity_direction = -global_transform.basis.y.normalized()
