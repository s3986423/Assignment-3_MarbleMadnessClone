extends StaticBody3D

@export var swing_speed: float = 2.0
@export var swing_angle: float = 45.0
var time: float = 0.0
var random_offset: float

func _ready() -> void:
	random_offset = randf() * PI * 2

func _process(delta: float) -> void:
	time += delta
	var angle = sin(time * swing_speed + random_offset) * deg_to_rad(swing_angle)
	rotation.z = angle
