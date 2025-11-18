extends CharacterBody3D

const SPEED = 7.0
const JUMP_VELOCITY = 8.0
const ACCELERATION = 15.0
const FRICTION = 5.0
const SLOPE_FORCE = 15.0
const MIN_SLOPE_ANGLE = 5.0
const BALL_RADIUS = 0.5
const AIR_RESISTANCE = 0.98

# Air control constants
const AIR_ACCELERATION = 30.0
const AIR_SPEED_MULTIPLIER = 0.8  # Allow 80% of ground speed in air
const AIR_FRICTION = 10.0

const CAMERA_DISTANCE = 4.0
const CAMERA_HEIGHT = 3.0
const MOUSE_SENSITIVITY = 0.002
const CAMERA_PITCH_LIMIT = 80.0
const MAX_ATTACH_ANGLE_DEG = 45.0

@onready var ball_mesh = $PlayerSphere
@onready var camera = $PlayerCamera3D
@onready var rolling_sfx = $PlayerRollingSFX
@onready var colliding_sfx = $PlayerCollidingSFX

# Track collision state for SFX
var was_colliding = false

var angular_velocity = Vector3.ZERO

# Camera control variables
var camera_yaw = 0.0
var camera_pitch = -20.0
var mouse_captured = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Store the initial spawn position
	spawn_position = global_position

func _process(_delta: float) -> void:
	# Continuously sync mouse state with pause state
	sync_mouse_with_pause_state()

func _input(event: InputEvent) -> void:
	# Only handle ESC when game is NOT paused (let pause menu handle it when paused)
	if event.is_action_pressed("ui_cancel") and not get_tree().paused: # ESC key
		# First toggle pause through GameManager
		var game_manager = get_node("/root/GameManager")
		if game_manager and is_instance_valid(game_manager):
			game_manager.toggle_pause()
		else:
			# Fallback: toggle pause directly
			get_tree().paused = !get_tree().paused
		
		# Sync mouse capture with pause state
		sync_mouse_with_pause_state()
	
	# Testing keys for death/respawn system
	if event.is_action_pressed("test_die"): # ENTER key - Manual death
		print("Manual death triggered!")
		die()

	if event.is_action_pressed("manual_respawn"): # R key - Manual respawn
		print("Manual respawn triggered!")
		respawn()
	
	if mouse_captured and event is InputEventMouseMotion:
		handle_mouse_look(event.relative)

func _physics_process(delta: float) -> void:
	# Skip physics if dead
	if is_dead:
		return
	
	apply_gravity(delta)
	handle_jump()
	
	var input_direction = get_camera_relative_input()
	apply_movement_forces(input_direction, delta)
	apply_slope_forces(delta)
	handle_accelerators(delta)
	
	move_and_slide()
	
	handle_wall_collisions()
	update_ball_rotation(delta)
	update_mouse_camera()
	
	# Check for death conditions
	check_death_conditions()

	handle_rolling_sfx()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func get_camera_relative_input() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if input_dir.length() == 0:
		return Vector3.ZERO
	
	var camera_to_player = (global_position - camera.global_position).normalized()
	var camera_forward = Vector3(camera_to_player.x, 0, camera_to_player.z).normalized()
	var camera_right = Vector3(-camera_forward.z, 0, camera_forward.x)
	
	var world_direction = (camera_right * input_dir.x - camera_forward * input_dir.y)
	return Vector3(world_direction.x, 0, world_direction.z).normalized()

func apply_movement_forces(input_direction: Vector3, delta: float) -> void:
	if input_direction.length() > 0:
		var current_horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
		
		# Different behavior for ground vs air
		if is_on_floor():
			# Ground movement - original logic
			var current_speed_in_input_direction = current_horizontal_velocity.dot(input_direction)
			
			# Only accelerate if we're not already going faster than SPEED in that direction
			if current_speed_in_input_direction < SPEED:
				var acceleration_force = input_direction * ACCELERATION * delta
				velocity.x += acceleration_force.x
				velocity.z += acceleration_force.z
			# If already going faster, don't slow down - let momentum carry
		else:
			# Air movement - enhanced control
			var air_max_speed = SPEED * AIR_SPEED_MULTIPLIER
			var current_speed_in_input_direction = current_horizontal_velocity.dot(input_direction)
			
			# Allow more liberal air movement
			if current_speed_in_input_direction < air_max_speed:
				var air_acceleration_force = input_direction * AIR_ACCELERATION * delta
				velocity.x += air_acceleration_force.x
				velocity.z += air_acceleration_force.z
			
			# Allow some air strafing even at max speed
			var perpendicular_direction = Vector3(-input_direction.z, 0, input_direction.x)
			var perpendicular_speed = current_horizontal_velocity.dot(perpendicular_direction)
			
			if abs(perpendicular_speed) < air_max_speed * 0.5: # Allow 50% strafe speed
				var strafe_force = perpendicular_direction * (input_direction.x * AIR_ACCELERATION * 0.3 * delta)
				velocity.x += strafe_force.x
				velocity.z += strafe_force.z
	# else:
	apply_friction(delta)

func apply_friction(delta: float) -> void:
	if is_on_floor():
		# Ground friction - original behavior
		var friction_multiplier = get_friction_multiplier()
		velocity.x = move_toward(velocity.x, 0, FRICTION * friction_multiplier * delta)
		velocity.z = move_toward(velocity.z, 0, FRICTION * friction_multiplier * delta)
	else:
		# Air friction - much less resistance to preserve momentum
		velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0, AIR_FRICTION * delta)

func get_friction_multiplier() -> float:
	if not is_on_floor():
		return 1.0
	
	var floor_normal = get_floor_normal()
	var slope_angle = rad_to_deg(acos(floor_normal.dot(Vector3.UP)))
	return max(0.1, 1.0 - (slope_angle / 90.0))

func apply_slope_forces(delta: float) -> void:
	if not is_on_floor():
		return
	
	var floor_normal = get_floor_normal()
	var slope_angle = rad_to_deg(acos(floor_normal.dot(Vector3.UP)))
	
	if slope_angle > MIN_SLOPE_ANGLE:
		var downhill_direction = (Vector3.DOWN - floor_normal * Vector3.DOWN.dot(floor_normal)).normalized()
		var slope_force = downhill_direction * SLOPE_FORCE * (slope_angle / 90.0)
		velocity.x += slope_force.x * delta
		velocity.z += slope_force.z * delta

func handle_accelerators(delta: float) -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if collider and collider.is_in_group("accelerator"):
			var normal := collision.get_normal().normalized()
			var platform_up := Vector3(collider.global_transform.basis.y).normalized()
			var platform_forward := Vector3(collider.global_transform.basis.z).normalized()
			
			if normal.dot(platform_up) > cos(deg_to_rad(MAX_ATTACH_ANGLE_DEG)):
				if collider.has_method("get_acceleration"):
					var accel = collider.get_acceleration()
					velocity += platform_forward * accel * delta
				elif "acceleration" in collider:
					var accel = collider.acceleration
					velocity += platform_forward * accel * delta

func handle_wall_collisions() -> void:
	var collided = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		# Consider any collision with a non-upward normal as a wall or hard surface
		if abs(normal.y) < 0.7 or abs(normal.y) > 0.99:
			var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
			if is_on_floor() and horizontal_velocity.length() < 0.5:
				angular_velocity = Vector3.ZERO
			collided = true
			break
	# Play SFX only on new collision
	if collided and not was_colliding:
		play_colliding_sfx()
	was_colliding = collided

func play_colliding_sfx() -> void:
	if not colliding_sfx.playing:
		colliding_sfx.play()

func handle_rolling_sfx() -> void:
	var is_rolling = is_on_floor() and Vector3(velocity.x, 0, velocity.z).length() > 0.1
	if is_rolling:
		if not rolling_sfx.playing:
			rolling_sfx.play()
	else:
		if rolling_sfx.playing:
			rolling_sfx.stop()

func update_ball_rotation(delta: float) -> void:
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	if is_on_floor():
		if horizontal_velocity.length() > 0.1:
			var distance_moved = horizontal_velocity.length() * delta
			var rotation_amount = distance_moved / BALL_RADIUS
			var rotation_axis = Vector3(0, 1, 0).cross(horizontal_velocity.normalized())
			angular_velocity = rotation_axis * (rotation_amount / delta)
		else:
			angular_velocity = angular_velocity.move_toward(Vector3.ZERO, FRICTION * 2.0 * delta)
	else:
		angular_velocity *= pow(AIR_RESISTANCE, delta)
	
	if angular_velocity.length() > 0.01:
		ball_mesh.rotate(angular_velocity.normalized(), angular_velocity.length() * delta)

func handle_mouse_look(mouse_delta: Vector2) -> void:
	camera_yaw += mouse_delta.x * MOUSE_SENSITIVITY
	camera_pitch += mouse_delta.y * MOUSE_SENSITIVITY * 25.0
	camera_pitch = clamp(camera_pitch, -CAMERA_PITCH_LIMIT, CAMERA_PITCH_LIMIT)

func update_mouse_camera() -> void:
	# Calculate camera position based on yaw and pitch
	var offset = Vector3(
		cos(camera_yaw) * cos(deg_to_rad(camera_pitch)) * CAMERA_DISTANCE,
		sin(deg_to_rad(camera_pitch)) * CAMERA_DISTANCE + CAMERA_HEIGHT,
		sin(camera_yaw) * cos(deg_to_rad(camera_pitch)) * CAMERA_DISTANCE
	)
	
	camera.global_position = global_position + offset
	camera.look_at(global_position, Vector3.UP)

func toggle_mouse_capture() -> void:
	mouse_captured = !mouse_captured
	if mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		print("Mouse captured - Camera control enabled")
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		print("Mouse freed - Camera control disabled")

func sync_mouse_with_pause_state() -> void:
	var is_game_paused = get_tree().paused
	
	# When game is paused, free the mouse
	if is_game_paused and mouse_captured:
		mouse_captured = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		print("Game paused - Mouse freed")
	
	# When game is unpaused, capture the mouse
	elif not is_game_paused and not mouse_captured:
		mouse_captured = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		print("Game resumed - Mouse captured")

# Death and respawn system
var is_dead = false
var spawn_position = Vector3.ZERO
var original_material: Material

func die() -> void:
	if is_dead:
		return # Prevent multiple death calls
	
	is_dead = true
	print("Player died!")
	
	# Stop all movement
	velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	ball_mesh.visible = false

	# Optional: Add death effects here
	# Spawn shards
	var shard_count: int = 10
	var shard_size: float = 0.2
	var shard_speed: float = 6.0
	var shard_lifetime: float = 1.5
	for i in range(shard_count):
		var shard := MeshInstance3D.new()
		shard.mesh = SphereMesh.new()
		shard.mesh.radius = shard_size
		shard.mesh.height = shard_size * 2.0  # SphereMesh uses height too
		shard.scale = Vector3.ONE * randf_range(0.7, 1.3)

		# Place at ball’s current position
		shard.global_transform = global_transform

		# Give each shard a simple StandardMaterial so it looks like the ball
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1, 0.2, 0.2)  # red example
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		shard.material_override = mat

		# Add as child of the same parent so shards exist in world
		get_parent().add_child(shard)

		# Animate movement + fade out
		var dir = Vector3(randf_range(-1, 1), randf_range(0.3, 1), randf_range(-1, 1)).normalized()
		var tween = get_tree().create_tween()
		tween.tween_property(shard, "global_position", shard.global_position + dir * shard_speed, shard_lifetime)
		tween.parallel().tween_property(shard.material_override, "albedo_color:a", 0.0, shard_lifetime)
		tween.finished.connect(func():
			shard.queue_free()
		)
		
	await get_tree().create_timer(1.0).timeout
	respawn()
	
	# Death effect: Make the ball bounce up slightly and change color
	#velocity.y = 2.0 # Small bounce
	#if ball_mesh:
		## Store original material if not already stored
		#if not original_material and ball_mesh.get_surface_override_material_count() > 0:
			#original_material = ball_mesh.get_surface_override_material(0)
		#elif not original_material:
			#original_material = ball_mesh.get_surface_material(0)
		#
		## Create a red material for death effect
		#var death_material = StandardMaterial3D.new()
		#death_material.albedo_color = Color.RED
		#death_material.emission_enabled = true
		#death_material.emission = Color.RED * 0.3
		#ball_mesh.set_surface_override_material(0, death_material)
		#
		## Respawn after delay
		#await get_tree().create_timer(1.0).timeout
		#respawn()
	#else:
		## If no visual effects, respawn immediately after a short delay
		#await get_tree().create_timer(1.0).timeout
		#respawn()

func respawn() -> void:
	print("Player respawning...")
	ball_mesh.visible = true
	
	# Reset player state
	is_dead = false
	velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	# Move player back to spawn position
	global_position = spawn_position
	
	# Reset visual effects
	if ball_mesh and original_material:
		ball_mesh.set_surface_override_material(0, original_material)
	elif ball_mesh:
		# Clear any override material to use the default
		ball_mesh.set_surface_override_material(0, null)
	
	# Reset camera position
	camera_yaw = 0.0
	camera_pitch = -20.0
	update_mouse_camera()
	
	print("Player respawned!")

func set_spawn_position(new_spawn_position: Vector3) -> void:
	spawn_position = new_spawn_position
	print("Spawn position set to: ", spawn_position)

func check_death_conditions() -> void:
	if is_dead:
		return
	
	#if global_position.y < spawn_position.y - 50.0:
		#die()
