extends Control

# Level Complete Screen - Displays completion info and handles continuation

@onready var stars_label = $VBoxContainer/StarsLabel
@onready var time_label = $VBoxContainer/TimeLabel
@onready var continue_button = $VBoxContainer/ContinueButton
@onready var complete_sfx = $LevelCompleteSFX

var next_level_path: String = ""
var previous_mouse_mode: int = Input.MOUSE_MODE_CAPTURED
var hud_node: Node = null

func _ready() -> void:
	# Set process mode to always so it works even when game is paused
	process_mode = PROCESS_MODE_ALWAYS
	
	# Store current mouse mode and HUD state
	previous_mouse_mode = Input.get_mouse_mode()
	
	# Find and hide HUD
	_find_and_hide_hud()
	
	# Release mouse and pause game
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	
	# Connect continue button
	continue_button.connect("pressed", Callable(self, "_on_continue_pressed"))

	if complete_sfx:
		complete_sfx.play()

func _find_and_hide_hud() -> void:
	# Try to find HUD in current scene
	var current_scene = get_tree().current_scene
	if current_scene:
		# Common HUD node names
		var hud_names = ["HUD", "Hud", "UI", "UserInterface"]
		for hud_name in hud_names:
			if current_scene.has_node(hud_name):
				hud_node = current_scene.get_node(hud_name)
				if hud_node and "visible" in hud_node:
					hud_node.visible = false
					print("LevelCompleteScreen: HUD hidden")
					return
		
		# If not found by name, try to find any node that might be HUD
		for child in current_scene.get_children():
			if child and "visible" in child and child.name.to_lower().contains("hud"):
				hud_node = child
				hud_node.visible = false
				print("LevelCompleteScreen: HUD hidden")
				return
	
	print("LevelCompleteScreen: HUD not found")

# Called by GameManager to set the completion data
func set_completion_data(stars: int, time_taken: float, next_level: String) -> void:
	print("LevelCompleteScreen: Setting completion data - Stars: ", stars, ", Time: ", time_taken, ", Next: ", next_level)
	next_level_path = next_level
	
	# Ensure nodes are ready before setting text
	if not stars_label:
		stars_label = $VBoxContainer/StarsLabel
	if not time_label:
		time_label = $VBoxContainer/TimeLabel
	
	# Update stars display
	var stars_text = ""
	for i in range(stars):
		stars_text += "★"
	if stars_label:
		stars_label.text = stars_text
		print("LevelCompleteScreen: Stars label set to: ", stars_text)
	else:
		push_error("LevelCompleteScreen: StarsLabel not found!")
	
	# Update time display
	var time_text = "Time: %.2f seconds" % time_taken
	if time_label:
		time_label.text = time_text
		print("LevelCompleteScreen: Time label set to: ", time_text)
	else:
		push_error("LevelCompleteScreen: TimeLabel not found!")

func _on_continue_pressed() -> void:
	# Restore mouse mode
	Input.set_mouse_mode(previous_mouse_mode)
	
	# Unpause game
	get_tree().paused = false
	
	# Show HUD if it was hidden
	if hud_node:
		hud_node.visible = true
		print("LevelCompleteScreen: HUD shown")
	
	# Load the next level instead of restarting
	if next_level_path != "":
		GameManager.load_level(next_level_path)
	else:
		GameManager.restart_level()
	queue_free()  # Remove this screen
