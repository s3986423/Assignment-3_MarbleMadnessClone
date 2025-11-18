extends AnimatableBody3D

@export var move_time: float = 4.0
@export var wait_time: float = 0.2

var startpoint: Marker3D
var endpoint: Marker3D

func _ready() -> void:
	startpoint = $StartMarker
	endpoint = $EndMarker
	move()

func move() -> void:
	var move_tween = create_tween()
	move_tween.set_loops()
	move_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	move_tween.tween_property(self, "global_position", endpoint.global_position, move_time) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_delay(wait_time)
	move_tween.tween_property(self, "global_position", startpoint.global_position, move_time) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_delay(wait_time)
