extends Node3D

signal goal

@export var expected_time: float = 60.0  # Adjust this per level for 3-star rating

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		emit_signal("goal")
		GameManager.level_complete(expected_time)
