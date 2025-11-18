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
	# Call the global GameManager to resume the game
	if game_manager and is_instance_valid(game_manager):
		game_manager.restart_level()
		print("Game restarted")
	else:
		push_error("RestartButton: GameManager is not available")
		# Fallback: unpause directly
		if get_tree():
			get_tree().paused = false
			print("Game resumed directly (fallback)")
