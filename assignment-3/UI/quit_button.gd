extends Button

var game_manager: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	game_manager = get_node("/root/GameManager")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_pressed() -> void:
	# Quit the game
	print("Quitting game...")
	if get_tree():
		get_tree().quit()
	else:
		push_error("QuitButton: Cannot quit - scene tree is not available")
