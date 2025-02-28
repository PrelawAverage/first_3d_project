class_name PauseMenu extends Control

const PAUSE_MENU: PackedScene = preload("uid://c58fnfj4if2gr")

var player: Player

static func new_pause(p: Player) -> PauseMenu:
	var pause_menu: PauseMenu = PAUSE_MENU.instantiate()
	pause_menu.player = p 
	return pause_menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.isShowingUI = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_back"):
		_close()

func _on_back_button_pressed() -> void:
	_close()

func _on_main_menu_button_pressed() -> void:
	get_tree().quit()
	
func _close() -> void:
	print("Close")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.isShowingUI = false
	queue_free()  # Remove the pause menu
