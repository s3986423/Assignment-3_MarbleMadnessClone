extends Area3D

# Finish Area - Triggers level completion when player enters

@export var expected_time: float = 30.0
@export var next_level: String = "res://Characters/test_level.tscn"

func _ready() -> void:
	# Connect to body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Check if the entering body is the player
	if body.name == "PlayerCharacter" or body.is_in_group("player"):
		print("Finish Area: Player entered finish area")
		GameManager.level_complete(expected_time, next_level)
