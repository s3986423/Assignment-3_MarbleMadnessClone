extends StaticBody3D

@export var angular_velocity: float = 90.0

func _process(delta: float) -> void:
	constant_angular_velocity = Vector3.MODEL_RIGHT * deg_to_rad(angular_velocity)
	rotate(Vector3.MODEL_RIGHT, deg_to_rad(angular_velocity) * delta)
