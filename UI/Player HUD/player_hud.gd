class_name PlayerHUD extends Control

@onready var damage_overlay: TextureRect = $DamageOverlay
@onready var health_display: Label = $"VBoxContainer/Health Display"
@onready var gravity_display: Label = $"VBoxContainer/Gravity Display"
@onready var player: Player = $".."
var tween: Tween
var base_intensity: float

func _ready() -> void:
	damage_overlay.modulate.a = 0.0  # Start fully transparent

func _process(delta: float) -> void:
	# Update the health display text
	health_display.text = str(int(player.health))
	gravity_display.text = str(player.get_gravity().y)

	# Set the damage overlay based on health every frame
	var health_ratio: float = float(player.health) / float(player.max_health)
	base_intensity = 1.0 - health_ratio  # More transparent at full health

	# Update the damage overlay opacity based on health intensity
	damage_overlay.modulate.a = base_intensity

func _hurt_effect(damage: int) -> void:
	# If there's an existing tween, remove it to prevent overlap
	if tween and tween.is_running():
		tween.kill()

	# Calculate damage impact (stronger flash for more damage)
	var damage_intensity: float = float(damage) / float(player.max_health) * 2.0  # Scales impact
	var final_intensity: float = clamp(damage_intensity, 0.0, 1.0)  # Clamp between 0-1 for the flash intensity

	# Create a new tween
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	# Set the initial alpha (immediate flash)
	damage_overlay.modulate.a = final_intensity

	# Fade out smoothly to the health-based intensity
	tween.tween_property(damage_overlay, "modulate:a", base_intensity, 0.5)  # Gradual return to health-based intensity
