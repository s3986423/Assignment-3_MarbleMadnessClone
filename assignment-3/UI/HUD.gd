extends CanvasLayer

@onready var timer_label: Label = $Control/TimerLabel
@onready var level_label: Label = $Control/LevelLabel

var game_manager: Node

func _ready() -> void:
	game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.connect("timer_updated", Callable(self, "_on_timer_updated"))
		game_manager.connect("level_changed", Callable(self, "_on_level_changed"))
		_update_timer_display()
		_update_level_display()

func _process(_delta: float) -> void:
	if game_manager and game_manager.game_started and not game_manager.is_paused:
		_update_timer_display()

func _update_timer_display() -> void:
	if timer_label and game_manager:
		var current_time = game_manager.get_game_time()
		var minutes = int(current_time / 60.0)
		var seconds = int(current_time) % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]

func _update_level_display() -> void:
	if level_label and game_manager:
		var level_name = "Unknown"
		if game_manager.current_level == "res://Characters/test_level.tscn":
			level_name = "Test Level"
		elif game_manager.current_level == "res://Stages/stage_1.tscn":
			level_name = "Stage 1"
		elif game_manager.current_level == "res://Stages/stage_2.tscn":
			level_name = "Stage 2"
		elif game_manager.current_level == "res://Stages/stage_3.tscn":
			level_name = "Stage 3"
		level_label.text = "Level: " + level_name

func _on_timer_updated(_new_time: float) -> void:
	_update_timer_display()

func _on_level_changed(level_name: String) -> void:
	if level_label:
		level_label.text = "Level: " + level_name
