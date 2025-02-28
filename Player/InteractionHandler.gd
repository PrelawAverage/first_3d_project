# This script is attached to the player and is responsible for handling interactions with objects in the world.
class_name InteractionHandler extends RayCast3D

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and is_colliding():
		var object: Node3D = get_collider()
		if object.is_in_group("Interactable"):
			if object.has_method("interact"):
				object.call("interact")
