extends StaticBody3D

@export var launch_speed: float = 16.0
@export var offset: Vector3 = Vector3(0, 1, 0)

func _on_area_3d_body_entered(body: Node3D) -> void:
	var forward := global_transform.basis.z
	if body is CharacterBody3D and body.is_in_group('player'):
		body.velocity = forward.normalized() * launch_speed + offset
