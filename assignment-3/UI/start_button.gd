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
	# Call the global GameManager to start the game
	if game_manager and is_instance_valid(game_manager):
		game_manager.start_game()
		print("Game started")
	else:
		push_error("StartButton: GameManager is not available")
		# Fallback: try to load the level directly
		if get_tree():
			var error = get_tree().change_scene_to_file("res://Characters/test_level.tscn")
			if error != OK:
				push_error("StartButton: Failed to load level directly. Error: " + str(error))
