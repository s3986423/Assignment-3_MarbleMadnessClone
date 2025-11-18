extends CanvasLayer

# Called when the node enters the scene tree for the first time
func _ready():
	# Set process mode to PROCESS_MODE_WHEN_PAUSED so this can receive input even when paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

# Handle input when the game is paused
func _input(event):
	if event.is_action_pressed("ui_cancel") and get_tree().paused:  # ESC key only when paused
		GameManager.toggle_pause()
		get_viewport().set_input_as_handled()  # Consume the event so player script doesn't see it
