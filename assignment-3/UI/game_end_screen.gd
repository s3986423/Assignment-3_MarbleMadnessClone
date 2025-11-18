extends Control

@onready var return_button = $VBoxContainer/ReturnButton
@onready var complete_sfx = $GameEndSFX
var previous_mouse_mode: int = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	previous_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	return_button.connect("pressed", Callable(self, "_on_return_pressed"))
	if complete_sfx:
		complete_sfx.play()

func _on_return_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameManager.return_to_menu()
