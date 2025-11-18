extends StaticBody3D

@export var angular_velocity: float = 90.0

func _process(delta: float) -> void:
	rotate(Vector3.UP, deg_to_rad(angular_velocity) * delta)
