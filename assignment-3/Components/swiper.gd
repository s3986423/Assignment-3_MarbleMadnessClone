extends StaticBody3D

@export var angular_velocity: float = 90.0

func _process(delta: float) -> void:
	rotate(transform.basis.y.normalized(), deg_to_rad(angular_velocity) * delta)
