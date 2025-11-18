extends Node3D

@export var collapse_after: float = 5.0
@export var restore_after: float = 1.0
@export var reset_after: float = 5.0
@export var shake_intensity: float = 0.01
@export var shake_threshold: float = 0.7

@onready var mesh: MeshInstance3D = $floor_wood_2x6

var collapse_timer := 0.0
var restore_timer := 0.0
var reset_timer := 0.0
var bodies := []

var initial_position: Vector3
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	initial_position = global_position
	rng.randomize()

func _physics_process(delta: float) -> void:
	# print_debug("Timers: ", collapse_timer, ' ', restore_timer, ' ', reset_timer)
	# print_debug("Transperancy: ", mesh.transparency)
	if reset_timer > 0:
		reset_timer = move_toward(reset_timer, 0.0, delta)
		if reset_timer <= 0.0:
			var tween = create_tween()
			tween.tween_property(mesh, "transparency", 0, 0.5)
			tween.finished.connect(func():
				self.set_deferred("collision_layer", 1)
				self.set_deferred("collision_mask", 1)
			)
		return

	if bodies.size() == 0:
		restore_timer = move_toward(restore_timer, restore_after, delta)
		if restore_timer >= restore_after:
			collapse_timer = move_toward(collapse_timer, 0.0, delta * 0.5)
	else:
		collapse_timer = move_toward(collapse_timer, collapse_after, delta * bodies.size())
		restore_timer = 0.0

	# Add shaking when close to collapse
	if collapse_timer >= (collapse_after * shake_threshold):
		_apply_shake()
	else:
		mesh.global_position = initial_position
		
	if collapse_timer >= collapse_after:
		_collapse()

  
func _collapse() -> void:
	var tween = create_tween()
	tween.tween_property(mesh, "transparency", 1, 0.3)
	tween.finished.connect(func():
		self.set_deferred("collision_layer", 0)
		self.set_deferred("collision_mask", 0)
		reset_timer = reset_after
		restore_timer = 0
		collapse_timer = 0
	)

func _apply_shake() -> void:
	var offset = Vector3(
		rng.randf_range(-shake_intensity, shake_intensity),
		rng.randf_range(-shake_intensity, shake_intensity),
		rng.randf_range(-shake_intensity, shake_intensity)
	)
	mesh.global_position = initial_position + offset

func _on_area_3d_body_entered(body: Node3D) -> void:
	bodies.append(body)

func _on_area_3d_body_exited(body: Node3D) -> void:
	bodies.erase(body)
