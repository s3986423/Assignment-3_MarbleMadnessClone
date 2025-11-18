extends StaticBody3D

var spike = preload("res://Assets/KayKit_Platformer_Pack_1.0_FREE/neutral/strut_vertical.gltf")

@export var angular_velocity: float = 90.0
@export var spike_vertical_offset: float = 1.0
@export var spike_angular_offset: float = 30.0
@export var spike_scale: Vector3 = Vector3(0.5, 0.5, 0.5)
@export var spike_per_row: int = 2


func _ready() -> void:
	place_spikes()

func get_log_size() -> Vector3:
	var mesh_instance = $strut_horizontal
	var aabb: AABB = mesh_instance.get_aabb()
	var size: Vector3 = aabb.size * mesh_instance.scale
	return size

func place_spikes() -> void:
	var log_size = get_log_size()
	var log_length = log_size.x
	var log_radius = log_size.y / 2.0
	
	var start_x = - log_length / 2.0 + spike_vertical_offset
	var end_x = log_length / 2.0
	var current_x = start_x
	var current_angle = 0.0

	while current_x <= end_x:
		for i in range(spike_per_row):
			var angle = deg_to_rad(current_angle + i * (360.0 / spike_per_row))
			
			var spike_instance = spike.instantiate()
			add_child(spike_instance)
			
			var spike_base_height = 2.0 # Hardcoded height of the spike model
			spike_instance.position = Vector3(
				current_x,
				(log_radius + spike_base_height * spike_scale.y) * sin(angle),
				(log_radius + spike_base_height * spike_scale.y) * cos(angle)
			)
			spike_instance.rotate(Vector3.MODEL_RIGHT, angle + PI / 2)
			spike_instance.global_scale(spike_scale)

		current_x += spike_vertical_offset
		current_angle += spike_angular_offset

func _process(delta: float) -> void:
	constant_angular_velocity = Vector3.MODEL_RIGHT * deg_to_rad(angular_velocity)
	rotate(Vector3.MODEL_RIGHT, deg_to_rad(angular_velocity) * delta)
