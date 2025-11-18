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
	# Call the global GameManager to toggle pause
	if game_manager and is_instance_valid(game_manager):
		game_manager.toggle_pause()
		print("Pause toggled")
	else:
		push_error("PauseButton: GameManager is not available")
		# Fallback: toggle pause directly
		if get_tree():
			get_tree().paused = !get_tree().paused
			print("Pause toggled directly (fallback)")
