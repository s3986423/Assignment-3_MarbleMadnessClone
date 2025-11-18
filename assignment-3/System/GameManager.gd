extends Node

# GameManager - Global singleton for managing game state and scene transitions

# Scene paths
const START_MENU_SCENE = "res://UI/start_menu.tscn"
const STAGE_1_SCENE = "res://Stages/stage_1.tscn"
const STAGE_2_SCENE = "res://Stages/stage_2.tscn"
const STAGE_3_SCENE = "res://Stages/stage_3.tscn"
const PAUSE_MENU_SCENE = "res://UI/pause_menu.tscn"

# Current game state
var current_level: String = ""
var game_started: bool = false
var is_paused: bool = false

# Timer management
var game_timer: float = 0.0
var level_timer: float = 0.0
var timer_running: bool = false
var level_start_time: int = 0

# Signals
signal timer_updated(new_time: float)
signal level_changed(level_name: String)

func _ready() -> void:
	print("GameManager initialized")
	_validate_scene_paths()

func _process(delta: float) -> void:
	if timer_running and game_started and not is_paused:
		game_timer += delta
		level_timer += delta
		timer_updated.emit(game_timer)

# Validate that all required scene files exist
func _validate_scene_paths() -> void:
	var scenes_to_check = [START_MENU_SCENE, STAGE_1_SCENE, STAGE_2_SCENE, STAGE_3_SCENE, PAUSE_MENU_SCENE]
	for scene_path in scenes_to_check:
		if not ResourceLoader.exists(scene_path):
			push_error("GameManager: Required scene not found: " + scene_path)
			# Create a fallback error scene or handle gracefully
			break

# Toggle pause state with error handling
func toggle_pause() -> void:
	if not game_started:
		print("GameManager: Cannot pause - game not started")
		return

	# Check if scene tree is available
	if not is_instance_valid(get_tree()):
		push_error("GameManager: Scene tree is not available")
		return

	if not get_tree().current_scene:
		push_error("GameManager: No current scene available")
		return

	is_paused = !is_paused
	get_tree().paused = is_paused

	if is_paused:
		print("GameManager: Game paused")
		timer_running = false # Stop timer when paused
		var pause_result = _show_pause_menu()
		if not pause_result:
			push_error("GameManager: Failed to show pause menu")
	else:
		print("GameManager: Game resumed")
		timer_running = true # Resume timer when unpaused
		var hide_result = _hide_pause_menu()
		if not hide_result:
			push_warning("GameManager: Pause menu was not found to hide")

# Show pause menu with error handling
func _show_pause_menu() -> bool:
	if not is_instance_valid(get_tree()) or not get_tree().current_scene:
		push_error("GameManager: Cannot show pause menu - invalid scene tree")
		return false

	if get_tree().current_scene.has_node("PauseMenu"):
		print("GameManager: Pause menu already exists")
		return true

	# Try to load and instantiate pause menu
	var pause_menu_scene = load(PAUSE_MENU_SCENE)
	if not pause_menu_scene:
		push_error("GameManager: Failed to load pause menu scene: " + PAUSE_MENU_SCENE)
		return false

	var pause_menu_instance = pause_menu_scene.instantiate()
	if not pause_menu_instance:
		push_error("GameManager: Failed to instantiate pause menu")
		return false

	get_tree().current_scene.add_child(pause_menu_instance)
	print("GameManager: Pause menu shown")
	return true

# Hide pause menu with error handling
func _hide_pause_menu() -> bool:
	if not is_instance_valid(get_tree()) or not get_tree().current_scene:
		push_error("GameManager: Cannot hide pause menu - invalid scene tree")
		return false

	if not get_tree().current_scene.has_node("PauseMenu"):
		return false # Not an error, just nothing to hide

	var pause_menu = get_tree().current_scene.get_node("PauseMenu")
	if not is_instance_valid(pause_menu):
		push_error("GameManager: Pause menu node is invalid")
		return false

	pause_menu.queue_free()
	print("GameManager: Pause menu hidden")
	return true

# Start the game by loading the first level with error handling
func start_game() -> void:
	if not is_instance_valid(get_tree()):
		push_error("GameManager: Cannot start game - scene tree is not available")
		return

	print("GameManager: Starting game...")
	game_started = true
	current_level = STAGE_1_SCENE
	is_paused = false # Ensure game is not paused when starting
	get_tree().paused = false # Unpause the game tree
	timer_running = true # Start the timer
	game_timer = 0.0 # Reset game timer when starting fresh
	level_timer = 0.0 # Reset level timer
	level_start_time = Time.get_ticks_msec()
	timer_updated.emit(game_timer) # Update HUD immediately

	# Validate scene exists before attempting to load
	if not ResourceLoader.exists(STAGE_1_SCENE):
		push_error("GameManager: Start scene not found: " + STAGE_1_SCENE)
		game_started = false
		current_level = ""
		timer_running = false
		return

	var error = get_tree().change_scene_to_file(STAGE_1_SCENE)
	if error != OK:
		push_error("GameManager: Failed to change to start scene. Error code: " + str(error))
		game_started = false
		current_level = ""
		timer_running = false
		return

	level_changed.emit(_get_level_display_name(current_level))

# Return to the start menu with error handling
func return_to_menu() -> void:
	if not is_instance_valid(get_tree()):
		push_error("GameManager: Cannot return to menu - scene tree is not available")
		return

	print("GameManager: Returning to menu...")
	game_started = false
	current_level = ""
	is_paused = false # Ensure game is not paused when returning to menu
	get_tree().paused = false # Unpause the game tree
	timer_running = false # Stop timer when returning to menu

	# Validate scene exists before attempting to load
	if not ResourceLoader.exists(START_MENU_SCENE):
		push_error("GameManager: Start menu scene not found: " + START_MENU_SCENE)
		return

	var error = get_tree().change_scene_to_file(START_MENU_SCENE)
	if error != OK:
		push_error("GameManager: Failed to change to start menu scene. Error code: " + str(error))
		return

# Restart the current level with error handling
func restart_level() -> void:
	if not is_instance_valid(get_tree()):
		push_error("GameManager: Cannot restart level - scene tree is not available")
		return

	if current_level == "":
		push_error("GameManager: No current level to restart")
		return

	print("GameManager: Restarting level...")
	is_paused = false # Ensure game is not paused when restarting
	get_tree().paused = false # Unpause the game tree
	timer_running = true # Keep timer running
	game_timer = 0.0 # Reset game timer
	level_timer = 0.0 # Reset level timer
	level_start_time = Time.get_ticks_msec()
	timer_updated.emit(game_timer) # Update HUD immediately

	# Validate scene exists before attempting to load
	if not ResourceLoader.exists(current_level):
		push_error("GameManager: Current level scene not found: " + current_level)
		return

	var error = get_tree().change_scene_to_file(current_level)
	if error != OK:
		push_error("GameManager: Failed to restart level. Error code: " + str(error))
		return

# Load a specific level with comprehensive error handling
func load_level(level_path: String) -> void:
	if not is_instance_valid(get_tree()):
		push_error("GameManager: Cannot load level - scene tree is not available")
		return

	if level_path == "":
		push_error("GameManager: Level path cannot be empty")
		return

	# Validate scene exists before attempting to load
	if not ResourceLoader.exists(level_path):
		push_error("GameManager: Level scene not found: " + level_path)
		return

	print("GameManager: Loading level: ", level_path)

	# Store current level before attempting transition
	var previous_level = current_level
	current_level = level_path
	is_paused = false # Ensure game is not paused when loading new level
	get_tree().paused = false # Unpause the game tree
	timer_running = true # Keep timer running for new level
	game_timer = 0.0 # Reset game timer for new level
	level_timer = 0.0 # Reset level timer for new level
	level_start_time = Time.get_ticks_msec()
	timer_updated.emit(game_timer) # Update HUD immediately

	var error = get_tree().change_scene_to_file(level_path)
	if error != OK:
		push_error("GameManager: Failed to load level: " + level_path + ". Error code: " + str(error))
		# Restore previous level on failure
		current_level = previous_level
		return

	game_started = true
	level_changed.emit(_get_level_display_name(current_level))
# Utility to map scene path to display name
func _get_level_display_name(level_path: String) -> String:
	match level_path:
		STAGE_1_SCENE:
			return "Stage 1"
		STAGE_2_SCENE:
			return "Stage 2"
		STAGE_3_SCENE:
			return "Stage 3"
		"res://Characters/test_level.tscn":
			return "Test Level"
		_:
			return "Unknown"

# Get current game state for debugging
func get_game_state() -> Dictionary:
	return {
		"current_level": current_level,
		"game_started": game_started,
		"is_paused": is_paused,
		"scene_tree_valid": is_instance_valid(get_tree()),
		"current_scene_valid": is_instance_valid(get_tree().current_scene) if is_instance_valid(get_tree()) else false,
		"game_timer": game_timer,
		"level_timer": level_timer,
		"timer_running": timer_running
	}

# Level complete function with rating based on time
func level_complete(expected_time: float, next_level: String = "") -> void:
	if not game_started:
		push_error("GameManager: Cannot complete level - game not started")
		return

	var actual_time = game_timer # Use game_timer to match HUD display
	var stars = 1

	if actual_time <= expected_time - 10.0:
		stars = 3
	elif actual_time <= expected_time - 5.0:
		stars = 2

	print("GameManager: Level completed in ", actual_time, " seconds. Rating: ", stars, " stars")

	_show_level_complete_screen(stars, actual_time, next_level)

# Show level complete screen
func _show_level_complete_screen(stars: int, time_taken: float, next_level: String) -> void:
	if not is_instance_valid(get_tree()) or not get_tree().current_scene:
		push_error("GameManager: Cannot show level complete screen - invalid scene tree")
		return

	if get_tree().current_scene.has_node("LevelCompleteScreen"):
		print("GameManager: Level complete screen already exists")
		return

	var level_complete_scene = load("res://UI/level_complete_screen.tscn")
	if not level_complete_scene:
		push_error("GameManager: Failed to load level complete screen scene")
		return

	var level_complete_instance = level_complete_scene.instantiate()
	if not level_complete_instance:
		push_error("GameManager: Failed to instantiate level complete screen")
		return

	# Ensure the screen can process even when game is paused
	level_complete_instance.process_mode = Node.PROCESS_MODE_ALWAYS

	# Pass the completion data to the screen
	if level_complete_instance.has_method("set_completion_data"):
		level_complete_instance.set_completion_data(stars, time_taken, next_level)

	get_tree().current_scene.add_child(level_complete_instance)
	print("GameManager: Level complete screen shown")

# Timer management methods
func get_game_time() -> float:
	return game_timer

func get_level_time() -> float:
	return level_timer

func pause_timer() -> void:
	timer_running = false
	print("GameManager: Timer paused")

func resume_timer() -> void:
	if game_started and not is_paused:
		timer_running = true
		print("GameManager: Timer resumed")

func reset_game_timer() -> void:
	game_timer = 0.0
	level_timer = 0.0
	timer_updated.emit(game_timer)
	print("GameManager: Game timer reset")

func reset_level_timer() -> void:
	level_timer = 0.0
	print("GameManager: Level timer reset")

# Force reset game state (emergency recovery)
func force_reset() -> void:
	print("GameManager: Force resetting game state...")
	current_level = ""
	game_started = false
	is_paused = false
	timer_running = false
	game_timer = 0.0
	level_timer = 0.0

	if is_instance_valid(get_tree()):
		get_tree().paused = false
		# Try to return to start menu
		if ResourceLoader.exists(START_MENU_SCENE):
			var error = get_tree().change_scene_to_file(START_MENU_SCENE)
			if error != OK:
				push_error("GameManager: Failed to reset to start menu. Error code: " + str(error))
		else:
			push_error("GameManager: Cannot reset - start menu scene not found")
	else:
		push_error("GameManager: Cannot reset - scene tree is not available")

# Check if the game is in a valid state
func is_game_state_valid() -> bool:
	if not is_instance_valid(get_tree()):
		return false

	if not get_tree().current_scene:
		return false

	if game_started and current_level == "":
		return false

	return true
